# install dependencies

install.packages("cmdstanr", repos = c("https://mc-stan.org/r-packages/", getOption("repos")))
remotes::install_github('nicholasjclark/mvgam', force = TRUE)
install.packages(c( "portalr", "tidyr", "tidyverse", "dplyr", "vctrs",
	"lubridate", "rsample", "ggplot2", "ggpubr", "knitr", "pkgdown", 
	"rmarkdown", "testthat", "knitr"))

# install cmdstan
library(cmdstanr)
check_cmdstan_toolchain()
install_cmdstan()

# Test cmdstan
cmdstan_version()
