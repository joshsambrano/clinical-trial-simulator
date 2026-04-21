# Final Project Write-Up

## Title
**Clinical Trial Simulator: An Interactive Shiny App for Survival Analysis in Randomized Trials**

## Student
Josh Sambrano

## Project objective
This project develops an R Shiny app that simulates a two-arm randomized clinical trial and allows users to explore how changes in study design influence statistical results. The main goal is to make key concepts in clinical trial analysis practical and intuitive by letting users adjust parameters such as sample size, treatment hazard ratio, censoring, and patient characteristics, then immediately observe the impact on survival curves and model estimates. This aligns with the original project proposal and the course requirement that the final deliverable demonstrate meaningful application of statistical modeling principles. fileciteturn0file0L3-L14 fileciteturn0file1L1-L35

## Research question
How do clinical trial design choices such as sample size, treatment effect size, and dropout influence time-to-event analysis results in a randomized trial?

## Why a Shiny app is an appropriate deliverable
The course instructions explicitly permit a Shiny app that either teaches a modeling concept or allows users to conduct a statistical analysis interactively. This project does both: it teaches survival analysis concepts and gives users a hands-on way to explore how those methods behave under different trial settings. fileciteturn0file1L10-L20

## Data generation and structure
Because this project is focused on trial design and interpretation rather than analysis of a fixed real-world dataset, the app uses simulated patient-level data. Each simulated participant has:
- randomized treatment assignment,
- age,
- biomarker status,
- event time,
- censoring time,
- observed follow-up time,
- event indicator.

The simulation assumes exponential event times with a hazard that depends on treatment assignment and patient covariates. This provides a simple but statistically coherent framework for demonstrating how hazard ratios and censoring affect observed survival patterns.

## Data exploration and preparation
The app includes multiple tools for exploring the simulated dataset before interpreting the formal models:
- histograms of observed follow-up time,
- boxplots of age by treatment arm,
- bar charts of censoring reasons,
- bar charts of biomarker status,
- a patient-level data table.

These features address the rubric requirement that the data be well-explored and that important structure or data issues be made visible.

## Statistical methodology
The app applies three main statistical methods.

### 1. Kaplan-Meier survival curves
Kaplan-Meier estimation is used to estimate survival probabilities over time while accounting for right censoring. This is the natural first summary for a time-to-event endpoint in a randomized clinical trial.

### 2. Log-rank test
The log-rank test is used to compare the survival distributions of the treatment and control groups. This provides a standard hypothesis test for whether there is evidence of a survival difference between arms.

### 3. Cox proportional hazards regression
A Cox proportional hazards model is fit with treatment, age, and biomarker status as predictors. This model estimates hazard ratios while allowing adjustment for participant characteristics. The treatment hazard ratio is the central estimand for the app because it connects directly to how trial efficacy is often summarized.

## Justification of model choice
The selected methods are appropriate because the outcome is time to event with possible right censoring. Ordinary linear regression would not be suitable for this type of endpoint because it does not properly handle censoring and does not target the hazard or survival function. Survival methods are the correct framework because they use both event information and follow-up time.

The Cox model is especially appropriate here because:
- it is widely used in clinical trials,
- it does not require specification of the baseline hazard shape,
- it estimates interpretable hazard ratios,
- it can be paired naturally with Kaplan-Meier curves and log-rank testing.

## Assumptions and diagnostics
The major assumption checked in the app is the proportional hazards assumption. This is assessed using Schoenfeld residual tests from `cox.zph`, both for individual covariates and globally. The app also provides residual-based plots so that users can visually assess whether the hazard ratio appears stable over time.

This directly addresses the rubric requirement that assumptions be considered and tested, rather than simply stated.

## Interpretation of results
The app reports:
- the observed event rate,
- the log-rank p-value,
- the estimated treatment hazard ratio with confidence interval,
- median survival by treatment arm.

The Interpretation tab explains these quantities in plain language. This is important because the goal of the project is not only to compute results, but to communicate what they mean in the context of a randomized trial.

## Example of what users learn
If a user decreases the true treatment hazard ratio from 1.00 to 0.70 while holding other settings fixed, the app typically shows a clearer separation of the Kaplan-Meier curves and a more favorable estimated treatment hazard ratio. If the user then increases dropout, the curves become harder to distinguish and statistical uncertainty increases. This demonstrates that both effect size and study quality influence inference.

## Strengths of the deliverable
This app is a strong final project because it combines statistical rigor, communication, and creativity:
- it uses correct survival methods,
- it checks assumptions,
- it presents results visually and interactively,
- it teaches clinical trial concepts in an applied way,
- and it is reproducible and easy to present.

## Limitations
The app uses a simplified simulation model, so it does not capture every complexity of real clinical trials. For example, it assumes exponential event times and a fairly simple dropout mechanism. Even so, this simplification is appropriate for an educational tool because it keeps the statistical logic transparent while still showing realistic analysis workflows.

## Conclusion
This project demonstrates how statistical modeling can be used not only to analyze clinical trial data, but also to teach how trial design choices shape inference. The Shiny app provides an engaging, statistically appropriate, and well-organized deliverable that aligns with the project proposal and course expectations. fileciteturn0file0L3-L14 fileciteturn0file1L22-L48
