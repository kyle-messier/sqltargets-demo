#!/bin/bash

#SBATCH --job-name=sqltargets
#SBATCH --mail-user=kyle.messier@nih.gov
#SBATCH --mail-type=END,FAIL
#SBATCH --partition=highmem
#SBATCH --ntasks=1
#SBATCH --mem=100G
#SBATCH --cpus-per-task=4
#SBATCH --error=slurm/cov_%j.err
#SBATCH --output=slurm/cov_%j.out

############################      CERTIFICATES      ############################
# Export CURL_CA_BUNDLE and SSL_CERT_FILE environmental variables to vertify
# servers' SSL certificates during download.
export CURL_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
export SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt



# Download and calculate covariates via container_covariates.sif
apptainer exec \
  --bind $PWD:/mnt \
  --bind $PWD/_targets:/opt/_targets \
  --bind /run/munge:/run/munge \
  --bind /ddn/gs1/tools/slurm/etc/slurm:/ddn/gs1/tools/slurm/etc/slurm \
  container_covariates.sif \
  /usr/local/lib/R/bin/Rscript --no-init-file /mnt/run_container.R
