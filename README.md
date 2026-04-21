# Clinical Trial Simulator Shiny App

## Project overview
This project is an interactive Shiny application that simulates a two-arm randomized clinical trial and shows how different study design choices affect time-to-event analysis.: This project utilizes the following: **simulated patient-level data**, **Kaplan-Meier curves**, a **log-rank test**, and **Cox proportional hazards regression** to demonstrate treatment effects and survival differences in an applied, educational way.

## Research objective
To help users understand how randomized clinical trial design choices influence survival analysis results, including:
- survival curves,
- estimated treatment hazard ratios,
- statistical significance,
- censoring patterns,
- and proportional hazards diagnostics.

## Core methods
The app uses the following statistical tools:
1. **Simulated survival data generation** under an exponential time-to-event model.
2. **Kaplan-Meier estimation** for survival probability under censoring.
3. **Log-rank test** to compare survival curves between treatment groups.
4. **Cox proportional hazards regression** to estimate the adjusted treatment effect.
5. **Schoenfeld residual diagnostics (`cox.zph`)** to assess the proportional hazards assumption.

## Inputs users can change
- total sample size,
- true treatment hazard ratio,
- baseline monthly hazard,
- dropout hazard,
- administrative censoring time,
- mean age and age variability,
- biomarker prevalence,
- random seed.

## Outputs shown in the app
- Kaplan-Meier survival curves with confidence bands,
- median survival by arm,
- patient-level simulated data table,
- distribution plots for follow-up time, age, censoring, and biomarker status,
- multivariable Cox model coefficient table,
- hazard ratio forest plot,
- proportional hazards diagnostic table and plots,
- narrative interpretation tied to the simulated results.

## Files
- `app.R`: complete Shiny application
- `README.md`: project summary, rationale, and rubric alignment
- `PROJECT_REPORT.md`: polished write-up you can adapt into your final submission narrative

## Packages needed
Install these packages before running the app:

```r
install.packages(c("shiny", "ggplot2", "dplyr", "survival", "DT", "bslib", "tidyr"))
```

## Run app via


```r
shiny::runApp()
```

## Suggested workflow
1. Introduce the clinical trial question and design.
2. Show how changing the true hazard ratio changes the Kaplan-Meier curves.
3. Increase dropout and explain what censoring does to precision and interpretation.
4. Compare small and large sample sizes to discuss power.
5. Review the Cox model and proportional hazards diagnostics.
6. Conclude with how design assumptions affect inference.
