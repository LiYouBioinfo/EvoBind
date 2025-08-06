#!/usr/bin/env bash
set -euo pipefail

# A simple logger function
log() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"
}

# Create a log file
LOGFILE="${HOME}/EvoBind/prepare_data.$(date +'%Y%m%d_%H%M%S').log"
mkdir -p "$(dirname "$LOGFILE")"
exec > >(tee -a "$LOGFILE") 2>&1

log "=== Starting data preparation ==="

# ── 1. Prepare AlphaFold parameters ──────────────────────────────────────────
log "Creating AF2 params directory: ${HOME}/EvoBind/params"
mkdir -p "${HOME}/EvoBind/params"
cd "${HOME}/EvoBind/params"

log "Downloading AF2 parameters from S3: alphafold_params_2021-07-14.tar"
# show progress bar, no --quiet
aws s3 cp s3://crayonai.us-east-1/data/alphafold_params_2021-07-14.tar ./ \
    --only-show-errors

log "Extracting AF2 parameters"
tar -xf alphafold_params_2021-07-14.tar

log "Removing AF2 tarball"
rm alphafold_params_2021-07-14.tar

# ── 2. Prepare UniClust30 database ──────────────────────────────────────────
log "Creating UniClust30 directory: ${HOME}/EvoBind/data"
mkdir -p "${HOME}/EvoBind/data"
cd "${HOME}/EvoBind/data"

log "Downloading UniClust30 archive from S3"
aws s3 cp s3://crayonai.us-east-1/data/uniclust30_2018_08_hhsuite.tar.gz ./ \
    --only-show-errors

log "Extracting UniClust30 database"
tar -zxvf uniclust30_2018_08_hhsuite.tar.gz

log "Removing UniClust30 tarball"
rm uniclust30_2018_08_hhsuite.tar.gz

log "=== Data preparation complete ==="
log "AF2 params directory: ${HOME}/EvoBind/params"
log "UniClust30 DB directory: ${HOME}/EvoBind/data"
log "Full log written to ${LOGFILE}"
