#!/bin/bash
#SBATCH --job-name=mvgam_dryrun
#SBATCH --mail-user=pdumandan@ufl.edu
#SBATCH --ntasks=1
#SBATCH --mem=16gb
#SBATCH --time= 05:30:00
#SBATCH --partition=hpg2-compute
#SBATCH --output=/blue/ewhite/pdumandan/portal/mvgam_dryrun_output.log
#SBATCH --error=/blue/ewhite/pdumandan/portal/mvgam_dryrun_error.log

echo "INFO [$(date "+%Y-%m-%d %H:%M:%S")] Loading required modules"
source /etc/profile.d/modules.sh

module load git R

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

echo "INFO [$(date "+%Y-%m-%d %H:%M:%S")] Updating mvgamportal repository"
rm -rf mvgamportal
git clone https://github.com/weecology/mvgamportal.git
cd mvgamportal

Rscript R/dm-sample.R
