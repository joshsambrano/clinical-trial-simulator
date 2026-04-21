library(shiny)
library(ggplot2)
library(dplyr)
library(survival)
library(DT)
library(bslib)
library(tidyr)

#-----------------------------
# Helpers
#-----------------------------

simulate_trial_data <- function(n_total = 300,
                                hr_treatment = 0.75,
                                baseline_hazard = 0.08,
                                dropout_rate = 0.02,
                                admin_censor_time = 24,
                                age_mean = 60,
                                age_sd = 10,
                                biomarker_prev = 0.40,
                                beta_age = log(1.15) / 10,
                                beta_biomarker = log(1.40),
                                seed = 123) {
  set.seed(seed)

  n_control <- floor(n_total / 2)
  n_treat <- n_total - n_control

  dat <- tibble(
    id = seq_len(n_total),
    treatment = factor(rep(c("Control", "Treatment"), times = c(n_control, n_treat))),
    trt = ifelse(treatment == "Treatment", 1, 0),
    age = round(rnorm(n_total, mean = age_mean, sd = age_sd)),
    biomarker = rbinom(n_total, size = 1, prob = biomarker_prev)
  )

  dat$age_centered10 <- (dat$age - age_mean) / 10

  lp <- log(hr_treatment) * dat$trt + beta_age * dat$age_centered10 + beta_biomarker * dat$biomarker
  event_rate <- baseline_hazard * exp(lp)

  true_event_time <- rexp(n_total, rate = event_rate)
  dropout_time <- rexp(n_total, rate = dropout_rate)
  observed_time <- pmin(true_event_time, dropout_time, admin_censor_time)
  status <- as.integer(true_event_time <= dropout_time & true_event_time <= admin_censor_time)

  dat %>%
    mutate(
      true_event_time = true_event_time,
      dropout_time = dropout_time,
      time = observed_time,
      status = status,
      censor_reason = case_when(
        status == 1 ~ "Event",
        dropout_time < true_event_time & dropout_time < admin_censor_time ~ "Dropout",
        TRUE ~ "Administrative censoring"
      ),
      biomarker_label = factor(ifelse(biomarker == 1, "Positive", "Negative"))
    )
}

km_plot_df <- function(fit) {
  s <- summary(fit)
  if (length(s$time) == 0) return(tibble())

  strata_names <- if (is.null(s$strata)) rep("All", length(s$time)) else as.character(s$strata)
  tibble(
    time = s$time,
    surv = s$surv,
    upper = s$upper,
    lower = s$lower,
    n_risk = s$n.risk,
    n_event = s$n.event,
    strata = gsub("treatment=", "", strata_names)
  )
}

median_survival_by_arm <- function(dat) {
  fit <- survfit(Surv(time, status) ~ treatment, data = dat)
  out <- summary(fit)$table
  if (is.null(dim(out))) {
    out <- matrix(out, nrow = 1)
    rownames(out) <- "treatment=All"
  }
  tibble(
    treatment = gsub("treatment=", "", rownames(out)),
    median_survival = out[, "median"],
    lower_95 = out[, "0.95LCL"],
    upper_95 = out[, "0.95UCL"]
  )
}

cox_forest_df <- function(fit) {
  s <- summary(fit)
  tibble(
    term = rownames(s$coefficients),
    estimate = s$coefficients[, "coef"],
    hr = s$conf.int[, "exp(coef)"],
    lower = s$conf.int[, "lower .95"],
    upper = s$conf.int[, "upper .95"],
    p_value = s$coefficients[, "Pr(>|z|)"]
  )
}

#-----------------------------
# UI
#-----------------------------

ui <- fluidPage(
  theme = bs_theme(version = 5, bootswatch = "flatly", base_font = font_google("Inter")),

  tags$head(
    tags$style(HTML(" 
      .hero-box {
        background: linear-gradient(135deg, #103c68 0%, #1c6ea4 100%);
        color: white;
        padding: 24px;
        border-radius: 16px;
        margin-bottom: 18px;
      }
      .metric-card {
        background: #f8f9fa;
        border-radius: 14px;
        padding: 16px;
        min-height: 120px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.05);
        margin-bottom: 12px;
      }
      .section-note {
        background: #eef6ff;
        border-left: 5px solid #1c6ea4;
        padding: 12px 14px;
        border-radius: 8px;
        margin-bottom: 12px;
      }
      .small-label {
        font-size: 0.9rem;
        color: #4d5b68;
      }
    "))
  ),

  titlePanel("Clinical Trial Simulator: Survival Analysis in a Randomized Trial"),

  div(class = "hero-box",
      h3("Interactive final project deliverable"),
      p("This Shiny app simulates a two-arm randomized clinical trial and demonstrates how design choices influence Kaplan-Meier curves, log-rank tests, and Cox proportional hazards regression."),
      p(strong("Research objective:"),
        "Show how sample size, treatment hazard ratio, dropout, and patient characteristics affect statistical conclusions in time-to-event analysis.")
  ),

  sidebarLayout(
    sidebarPanel(
      width = 3,
      h4("Simulation controls"),
      numericInput("seed", "Random seed", value = 123, min = 1),
      sliderInput("n_total", "Total sample size", min = 100, max = 1000, value = 300, step = 20),
      sliderInput("hr_treatment", "True treatment hazard ratio", min = 0.40, max = 1.40, value = 0.75, step = 0.05),
      sliderInput("baseline_hazard", "Baseline monthly hazard", min = 0.02, max = 0.20, value = 0.08, step = 0.01),
      sliderInput("dropout_rate", "Monthly dropout hazard", min = 0.00, max = 0.10, value = 0.02, step = 0.005),
      sliderInput("admin_censor_time", "Administrative censoring time (months)", min = 12, max = 48, value = 24, step = 1),
      sliderInput("age_mean", "Mean age", min = 40, max = 75, value = 60, step = 1),
      sliderInput("age_sd", "Age SD", min = 5, max = 18, value = 10, step = 1),
      sliderInput("biomarker_prev", "Biomarker positivity proportion", min = 0.10, max = 0.80, value = 0.40, step = 0.05),
      actionButton("simulate", "Simulate / Refresh Trial", class = "btn-primary")
    ),

    mainPanel(
      width = 9,
      tabsetPanel(
        tabPanel(
          "Overview",
          br(),
          fluidRow(
            column(4, div(class = "metric-card", h4(textOutput("event_rate_txt")), p("Observed event rate"), span(class = "small-label", "Based on all simulated participants."))),
            column(4, div(class = "metric-card", h4(textOutput("logrank_txt")), p("Log-rank p-value"), span(class = "small-label", "Small values indicate evidence of survival differences."))),
            column(4, div(class = "metric-card", h4(textOutput("coxhr_txt")), p("Estimated treatment HR"), span(class = "small-label", "From the multivariable Cox model.")))
          ),
          div(class = "section-note",
              strong("How to use this app:"),
              tags$ul(
                tags$li("Change the design inputs in the left panel."),
                tags$li("Compare the observed Kaplan-Meier curves across treatment groups."),
                tags$li("Review the Cox model output and proportional hazards diagnostics."),
                tags$li("Use the Interpretation tab to connect results back to clinical trial design.")
              )
          ),
          plotOutput("km_plot", height = "460px"),
          br(),
          h4("Median survival by treatment arm"),
          DTOutput("median_table")
        ),

        tabPanel(
          "Data Exploration",
          br(),
          fluidRow(
            column(6, plotOutput("time_hist", height = "320px")),
            column(6, plotOutput("age_plot", height = "320px"))
          ),
          fluidRow(
            column(6, plotOutput("censor_bar", height = "320px")),
            column(6, plotOutput("biomarker_bar", height = "320px"))
          ),
          br(),
          h4("Patient-level simulated data"),
          DTOutput("data_table")
        ),

        tabPanel(
          "Model Results",
          br(),
          h4("Cox proportional hazards regression"),
          DTOutput("cox_table"),
          br(),
          h4("Visual summary of hazard ratios"),
          plotOutput("forest_plot", height = "360px")
        ),

        tabPanel(
          "Assumptions & Diagnostics",
          br(),
          div(class = "section-note",
              strong("Model assumption focus:"),
              "The Cox model assumes proportional hazards, meaning that hazard ratios are approximately constant over time. The diagnostic table below reports the Schoenfeld residual test for each covariate and a global test."
          ),
          DTOutput("zph_table"),
          br(),
          plotOutput("zph_plot", height = "420px"),
          br(),
          h4("Why these methods are appropriate"),
          tags$ul(
            tags$li("Kaplan-Meier curves estimate survival probabilities under censoring."),
            tags$li("The log-rank test compares survival functions between randomized groups."),
            tags$li("The Cox model estimates adjusted hazard ratios without specifying the baseline hazard shape."),
            tags$li("The randomized design reduces confounding for treatment assignment, while age and biomarker status are included to improve precision.")
          )
        ),

        tabPanel(
          "Interpretation",
          br(),
          htmlOutput("interpretation_text"),
          br(),
          h4("Project takeaways"),
          tags$ol(
            tags$li("Increasing the sample size generally narrows uncertainty and can improve power."),
            tags$li("A lower true treatment hazard ratio tends to separate the Kaplan-Meier curves more clearly."),
            tags$li("Higher dropout can obscure treatment effects by increasing censoring."),
            tags$li("Statistical significance should be interpreted together with effect size, confidence intervals, and trial design assumptions.")
          )
        )
      )
    )
  )
)

#-----------------------------
# Server
#-----------------------------

server <- function(input, output, session) {

  sim_data <- eventReactive(input$simulate, {
    simulate_trial_data(
      n_total = input$n_total,
      hr_treatment = input$hr_treatment,
      baseline_hazard = input$baseline_hazard,
      dropout_rate = input$dropout_rate,
      admin_censor_time = input$admin_censor_time,
      age_mean = input$age_mean,
      age_sd = input$age_sd,
      biomarker_prev = input$biomarker_prev,
      seed = input$seed
    )
  }, ignoreNULL = FALSE)

  km_fit <- reactive({
    survfit(Surv(time, status) ~ treatment, data = sim_data())
  })

  cox_fit <- reactive({
    coxph(Surv(time, status) ~ treatment + age_centered10 + biomarker, data = sim_data())
  })

  logrank_test <- reactive({
    survdiff(Surv(time, status) ~ treatment, data = sim_data())
  })

  zph_test <- reactive({
    cox.zph(cox_fit())
  })

  output$event_rate_txt <- renderText({
    sprintf("%.1f%%", 100 * mean(sim_data()$status))
  })

  output$logrank_txt <- renderText({
    lr <- logrank_test()
    p <- 1 - pchisq(lr$chisq, df = length(lr$n) - 1)
    format.pval(p, digits = 3, eps = 0.001)
  })

  output$coxhr_txt <- renderText({
    hr <- exp(coef(cox_fit())["treatmentTreatment"])
    sprintf("%.2f", hr)
  })

  output$km_plot <- renderPlot({
    df <- km_plot_df(km_fit())

    ggplot(df, aes(x = time, y = surv, color = strata, fill = strata)) +
      geom_step(linewidth = 1.1) +
      geom_ribbon(aes(ymin = lower, ymax = upper), alpha = 0.15, color = NA) +
      labs(
        title = "Kaplan-Meier survival curves",
        x = "Follow-up time (months)",
        y = "Survival probability",
        color = "Arm",
        fill = "Arm"
      ) +
      coord_cartesian(ylim = c(0, 1)) +
      theme_minimal(base_size = 13)
  })

  output$median_table <- renderDT({
    med <- median_survival_by_arm(sim_data()) %>%
      mutate(across(where(is.numeric), ~ round(.x, 2)))
    datatable(med, rownames = FALSE, options = list(dom = 't', pageLength = 5))
  })

  output$time_hist <- renderPlot({
    ggplot(sim_data(), aes(x = time, fill = treatment)) +
      geom_histogram(bins = 30, alpha = 0.75, position = "identity") +
      labs(title = "Distribution of observed follow-up time", x = "Observed time (months)", y = "Count", fill = "Arm") +
      theme_minimal(base_size = 13)
  })

  output$age_plot <- renderPlot({
    ggplot(sim_data(), aes(x = treatment, y = age, fill = treatment)) +
      geom_boxplot(alpha = 0.8) +
      labs(title = "Age distribution by treatment arm", x = "Treatment arm", y = "Age (years)") +
      theme_minimal(base_size = 13) +
      theme(legend.position = "none")
  })

  output$censor_bar <- renderPlot({
    ggplot(sim_data(), aes(x = censor_reason, fill = treatment)) +
      geom_bar(position = "dodge") +
      labs(title = "Event and censoring outcomes", x = NULL, y = "Count", fill = "Arm") +
      theme_minimal(base_size = 13) +
      theme(axis.text.x = element_text(angle = 15, hjust = 1))
  })

  output$biomarker_bar <- renderPlot({
    ggplot(sim_data(), aes(x = biomarker_label, fill = treatment)) +
      geom_bar(position = "dodge") +
      labs(title = "Biomarker status by treatment arm", x = "Biomarker status", y = "Count", fill = "Arm") +
      theme_minimal(base_size = 13)
  })

  output$data_table <- renderDT({
    datatable(
      sim_data() %>%
        select(id, treatment, age, biomarker_label, time, status, censor_reason) %>%
        mutate(time = round(time, 2)),
      rownames = FALSE,
      options = list(pageLength = 10, scrollX = TRUE)
    )
  })

  output$cox_table <- renderDT({
    tbl <- cox_forest_df(cox_fit()) %>%
      mutate(across(where(is.numeric), ~ round(.x, 3)))
    datatable(tbl, rownames = FALSE, options = list(dom = 't', pageLength = 10))
  })

  output$forest_plot <- renderPlot({
    tbl <- cox_forest_df(cox_fit()) %>%
      mutate(term = recode(term,
                           "treatmentTreatment" = "Treatment vs Control",
                           "age_centered10" = "Age (per 10-year increase)",
                           "biomarker" = "Biomarker positive vs negative"))

    ggplot(tbl, aes(x = hr, y = reorder(term, hr))) +
      geom_point(size = 3, color = "#1c6ea4") +
      geom_errorbarh(aes(xmin = lower, xmax = upper), height = 0.15, color = "#1c6ea4") +
      geom_vline(xintercept = 1, linetype = "dashed", color = "firebrick") +
      scale_x_log10() +
      labs(title = "Adjusted hazard ratios from Cox model", x = "Hazard ratio (log scale)", y = NULL) +
      theme_minimal(base_size = 13)
  })

  output$zph_table <- renderDT({
    z <- zph_test()
    ztab <- as.data.frame(z$table)
    ztab$term <- rownames(ztab)
    rownames(ztab) <- NULL
    ztab <- ztab %>%
      select(term, chisq, df, p) %>%
      mutate(across(where(is.numeric), ~ round(.x, 4)))
    datatable(ztab, rownames = FALSE, options = list(dom = 't', pageLength = 10))
  })

  output$zph_plot <- renderPlot({
    z <- zph_test()
    oldpar <- par(no.readonly = TRUE)
    on.exit(par(oldpar))
    par(mfrow = c(1, 3))
    plot(z, col = "#1c6ea4", lwd = 2)
  })

  output$interpretation_text <- renderUI({
    dat <- sim_data()
    lr <- logrank_test()
    p <- 1 - pchisq(lr$chisq, df = length(lr$n) - 1)
    cfit <- summary(cox_fit())
    hr <- cfit$conf.int["treatmentTreatment", "exp(coef)"]
    lower <- cfit$conf.int["treatmentTreatment", "lower .95"]
    upper <- cfit$conf.int["treatmentTreatment", "upper .95"]
    event_rate <- mean(dat$status)
    drop_rate <- mean(dat$censor_reason == "Dropout")

    HTML(sprintf(
      paste0(
        "<p>In this simulated randomized trial, <b>%.1f%%</b> of participants experienced the event of interest and <b>%.1f%%</b> were censored due to dropout or loss to follow-up. ",
        "The Kaplan-Meier analysis compares survival over time between the treatment and control groups, while the log-rank test evaluates whether the survival curves differ statistically.</p>",
        "<p>The estimated treatment hazard ratio from the Cox model is <b>%.2f</b> (95%% CI: <b>%.2f to %.2f</b>). ",
        "A hazard ratio below 1 suggests a lower event hazard in the treatment arm relative to control. The log-rank p-value is <b>%s</b>, which should be interpreted together with the effect size and the clinical relevance of the simulated treatment benefit.</p>",
        "<p>This app is intentionally educational: it shows how statistical conclusions depend not only on the true treatment effect, but also on sample size, censoring, and covariate distributions. Users can stress-test the design by increasing dropout, reducing sample size, or shrinking the treatment effect toward 1.</p>"
      ),
      100 * event_rate,
      100 * drop_rate,
      hr,
      lower,
      upper,
      format.pval(p, digits = 3, eps = 0.001)
    ))
  })
}

shinyApp(ui, server)
