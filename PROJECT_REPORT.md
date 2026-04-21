# Final Project Write-Up

## Title
**Clinical Trial Simulator: An Interactive Shiny App for Survival Analysis in Randomized Trials**

## Student
Josh Sambrano

## Project objective
This project develops an R Shiny app that simulates a two-arm randomized clinical trial and allows users to explore how changes in study design influence statistical results. The main goal is to make key concepts in clinical trial analysis practical and intuitive by letting users adjust parameters such as sample size, treatment hazard ratio, censoring, and patient characteristics, then immediately observe the impact on survival curves and model estimates. 

## Research question
How do clinical trial design choices such as sample size, treatment effect size, and dropout influence time-to-event analysis results in a randomized trial?

## Data generation and structure
Because this project is focused on trial design and interpretation rather than analysis of a fixed real-world dataset, the app uses simulated patient-level data. Each simulated participant has:
- randomized treatment assignment,
- age,
- biomarker status,
- event time,
- censoring time,
- observed follow-up time,
- event indicator.


## Statistical methodology
The app applies three main statistical methods.

### 1. Kaplan-Meier survival curves
Kaplan-Meier estimation is used to estimate survival probabilities over time while accounting for right censoring. This is the natural first summary for a time-to-event endpoint in a randomized clinical trial.

### 2. Log-rank test
The log-rank test is used to compare the survival distributions of the treatment and control groups. This provides a standard hypothesis test for whether there is evidence of a survival difference between arms.

### 3. Cox proportional hazards regression
A Cox proportional hazards model is fit with treatment, age, and biomarker status as predictors. This model estimates hazard ratios while allowing adjustment for participant characteristics. The treatment hazard ratio is the central estimand for the app because it connects directly to how trial efficacy is often summarized.

## Assumptions and diagnostics
The major assumption checked in the app is the proportional hazards assumption. The app also provides residual-based plots so that users can visually assess whether the hazard ratio appears stable over time.

## Interpretation of results
The app reports:
- the observed event rate,
- the log-rank p-value,
- the estimated treatment hazard ratio with confidence interval,
- median survival by treatment arm.

## Example of what users learn
If a user decreases the true treatment hazard ratio from 1.00 to 0.70 while holding other settings fixed, the app typically shows a clearer separation of the Kaplan-Meier curves and a more favorable estimated treatment hazard ratio. If the user then increases dropout, the curves become harder to distinguish and statistical uncertainty increases. This demonstrates that both effect size and study quality influence inference.

## Limitations
The app uses a simplified simulation model, so it does not capture a plethora of complexities of real clinical trials. 

## Conclusion
This project demonstrates how statistical modeling can be used not only to analyze clinical trial data, but also to teach how trial design choices shape inference. 
