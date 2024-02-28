#!/bin/bash
#SBATCH --job-name=mvgam_dryrun
#SBATCH --mail-user=pdumandan@ufl.edu
#SBATCH --ntasks=1
#SBATCH --mem=16gb
#SBATCH --time= 02:30:00
#SBATCH --partition=hpg2-compute
#SBATCH --output=/blue/ewhite/pdumandan/mvgam_dryrun_output.log
#SBATCH --error=/blue/ewhite/pdumandan/mvgam_dryrun_error.log

echo "INFO [$(date "+%Y-%m-%d %H:%M:%S")] Loading required modules"
source /etc/profile.d/modules.sh

module load git R


echo "INFO [$(date "+%Y-%m-%d %H:%M:%S")] Updating mvgamportal repository"
rm -rf mvgamportal
git clone https://github.com/weecology/mvgamportal.git
cd mvgamportal

Rscript R/dm-sample.R
