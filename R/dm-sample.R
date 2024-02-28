# Load packages
# Install required packages
if (!requireNamespace("remotes", quietly = TRUE)) {
  install.packages("remotes")
}

# Install mvgam from GitHub
remotes::install_github('nicholasjclark/mvgam', force = TRUE)

library(portalr)
library(mvgam)
library(tidyr)
library(ggpubr)
library(tidyverse)
library(dplyr)
library(vctrs)
library(lubridate)
library(rsample)

#' Generate data subsets
#'
#' Description of the function.
#'
#' @return A dataframe with generated data subsets.
generate_data_subsets <- function() {
  rodent_data <- summarize_rodent_data(
    path = get_default_data_path(),
    clean = FALSE,
    level = "Treatment",
    type = "Rodents",
    plots = "Longterm",
    unknowns = FALSE,
    shape = "crosstab",
    time = "all",
    output = "abundance",
    na_drop = FALSE,
    zero_drop = FALSE,
    min_traps = 1,
    min_plots = 1,
    effort = TRUE,
    download_if_missing = TRUE,
    quiet = FALSE
  )

  dmcont_dat <- rodent_data %>%
    filter(treatment %in% c("control", NA)) %>%
    select(censusdate, newmoonnumber, DM)

  covars <- weather(level = "newmoon", fill = TRUE, horizon = 365, path = get_default_data_path()) %>%
    select(newmoonnumber, meantemp, mintemp, maxtemp, precipitation, warm_precip, cool_precip)

  dmcont_covs <- right_join(covars, dmcont_dat, by = "newmoonnumber")

  dmdat <- dmcont_covs %>%
    rename(abundance = DM) %>%
    filter(!newmoonnumber > 526) %>%
    mutate(time = newmoonnumber - min(newmoonnumber) + 1) %>%
    mutate(series = as.factor('DM')) %>%
    select(time, censusdate, newmoonnumber, series, abundance, meantemp, warm_precip, cool_precip) %>%
    arrange(time)

  return(dmdat)
}

#' Apply sliding-index to create subsets of training data at different windows
#'
#' Description of the function.
#'
#' @param dmdat The input dataframe.
#'
#' @return A dataframe with sliding-index applied.
apply_sliding_index <- function(dmdat) {
  sliding_index(
    data = dmdat,
    newmoonnumber,
    lookback = 240,
    assess_stop = 12,
    complete = TRUE
  )
}

#' Fit, predict, score
#'
#' Description of the function.
#'
#' @param split The input split.
#'
#' @return A list containing the model, predictions, and score.
fit_predict_score <- function(split) {
  data_train <- analysis(split)
  data_test <- assessment(split)
  
  model <- mvgam(
    abundance ~ 1,
    trend_formula = ~ -1,
    trend_model = "AR1",
    family = poisson(link = "log"),
    data = data_train,
    newdata = data_test,
    priors = prior(normal(0, 2), class = Intercept),
    chains = 4,
    samples = 200
  )
  
  preds <- as.vector(forecast(model, data_test))
  get_score <- score(preds)
  
  return(list(model, preds, get_score))
}

#' Main function to run the entire process
#'
#' Description of the function.
#'
#' @export
run_main_process <- function() {
  dmdat <- generate_data_subsets()
  dmdat20 <- apply_sliding_index(dmdat)
  
  # Shorter subset moving window for different lengths of training data
  dmdat20v1 <- dmdat20[1:5,]
  
  # Fit, predict, score
  dmdat20v1$output <- map(dmdat20v1$splits, fit_predict_score)
  
  saveRDS(dmdat20v1, "mvgam-sample-output.RDS")
}

# Run the main process
run_main_process()
