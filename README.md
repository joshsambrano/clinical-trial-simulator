# Clinical Trial Simulator Shiny App

## Project overview
This project is an interactive Shiny application that simulates a two-arm randomized clinical trial and shows how study design choices affect time-to-event analysis. The app was built to match the final project proposal: a **Clinical Trial Simulator** using **simulated patient-level data**, **Kaplan-Meier curves**, a **log-rank test**, and **Cox proportional hazards regression** to demonstrate treatment effects and survival differences in an applied, educational way. This directly reflects the submitted project plan and course final project instructions. fileciteturn0file0L1-L14 fileciteturn0file1L1-L35

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

## Why this project meets the rubric
### 1. Statistical rigor and methodology
The app uses methods that are appropriate for censored time-to-event outcomes. The treatment effect is modeled with a Cox proportional hazards model, and survival experience is summarized with Kaplan-Meier curves and a log-rank test.

### 2. Interpretation and communication
The app includes an interpretation tab that translates the statistical output into plain language and ties the results back to the research objective.

### 3. Quality and creativity of deliverable
The deliverable is an interactive teaching and analysis tool rather than a static report. Users can actively change the design inputs and immediately see how the conclusions change.

### 4. Data exploration and preparation
The app generates patient-level data and includes summary visualizations for age, follow-up time, censoring, and biomarker prevalence so the dataset can be explored before interpreting the model.

### 5. Justification of model choice and assumptions
The app explicitly explains why survival methods are appropriate and includes Cox proportional hazards diagnostics using Schoenfeld residual tests.

### 6. Organization and professionalism
The app is organized into five tabs: Overview, Data Exploration, Model Results, Assumptions & Diagnostics, and Interpretation.

## Files
- `app.R`: complete Shiny application
- `README.md`: project summary, rationale, and rubric alignment
- `PROJECT_REPORT.md`: polished write-up you can adapt into your final submission narrative

## Packages needed
Install these packages before running the app:

```r
install.packages(c("shiny", "ggplot2", "dplyr", "survival", "DT", "bslib", "tidyr"))
```

## Run the app
From the project folder:

```r
shiny::runApp()
```

Or directly:

```r
source("app.R")
```

## Suggested presentation/demo flow
1. Introduce the clinical trial question and design.
2. Show how changing the true hazard ratio changes the Kaplan-Meier curves.
3. Increase dropout and explain what censoring does to precision and interpretation.
4. Compare small and large sample sizes to discuss power.
5. Review the Cox model and proportional hazards diagnostics.
6. Conclude with how design assumptions affect inference.
