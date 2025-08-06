#!/usr/bin/env bash
set -euo pipefail

######################################### 
##    ==========CRITICAL!!!========== 
## Run deploy_dataset.sh first to get the data from s3. 
## After deploy_dataset.sh, the AF2 params and uniclust30 datasets will be saved to $HOME/evobind/params and $HOME/evobind/data, respectively
#########################################


# ── 1) Load the image from S3
#    --quiet suppresses per-file progress; errors will still be shown
aws s3 cp s3://crayonai.us-east-1/evobind-full.tar - --only-show-errors | docker load

# ── 3) Launch an interactive container for debugging
docker run --rm -it \
  --name evobind_debug \
  --gpus all \
  -v "$HOME/evobind/params":/opt/EvoBind/src/AF2/params:ro \
  -v "$HOME/evobind/data":/opt/EvoBind/data \
  --entrypoint bash \
  evobind-full
