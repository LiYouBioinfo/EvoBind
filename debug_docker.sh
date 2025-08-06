#!/usr/bin/env bash
set -euo pipefail

######################################### 
##    ==========CRITICAL!!!========== 
## Run deploy_dataset.sh first to get the data from s3. 
## After deploy_dataset.sh, the AF2 params and uniclust30 datasets will be saved to $HOME/evobind/params and $HOME/evobind/data, respectively
#########################################


# ── 1) Download the pre–built Docker image tarball from S3
#    --quiet suppresses per-file progress; errors will still be shown
aws s3 cp s3://crayonai.docker/evobind-full.tar ./ --quiet

# ── 2) Load the image into your local Docker registry
#    This populates the image named "evobind-full:latest"
docker load -i evobind-full.tar

# ── 3) Launch an interactive container for debugging
docker run --rm -it \
  --name evobind_debug \
  --gpus all \
  -v "$HOME/evobind/params":/opt/EvoBind/src/AF2/params:ro \
  -v "$HOME/evobind/data":/opt/EvoBind/data \
  --entrypoint bash \
  evobind-full
