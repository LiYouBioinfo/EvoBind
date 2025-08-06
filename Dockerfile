# syntax=docker/dockerfile:1
FROM nvidia/cuda:12.5.1-runtime-ubuntu22.04

SHELL ["/bin/bash", "-lc"]
ARG DEBIAN_FRONTEND=noninteractive

# 1) Install OS dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      git \
      cmake \
      build-essential \
      wget \
      bzip2 \
      ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# 2) Install Miniconda (provides conda & pip)
ENV CONDA_DIR=/opt/conda \
    PATH=/opt/conda/bin:$PATH
RUN wget -qO /tmp/miniconda.sh \
      https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    bash /tmp/miniconda.sh -b -p "$CONDA_DIR" && \
    rm /tmp/miniconda.sh && \
    conda clean -afy && \
    conda activate evobind && \
    pip install --upgrade "jax[cuda12_pip]==0.4.30" -f https://storage.googleapis.com/jax-releases/jax_cuda_releases.html && \
    conda deactivate

# 3) Enable 'conda activate' in non-interactive shells
RUN conda init bash

# 4) Clone your EvoBind repo
WORKDIR /opt
RUN git clone https://github.com/LiYouBioinfo/EvoBind.git EvoBind

# 5) Create the evobind env & upgrade JAX, after accepting ToS
WORKDIR /opt/EvoBind
RUN source /opt/conda/etc/profile.d/conda.sh && \
    # Accept Anaconda ToS for default channels
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main && \
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r && \
    # Create the environment, clean cache, upgrade JAX via pip
    conda env create -f environment.yml && \
    conda clean -afy

# 6) Build HH-suite from source
RUN git clone https://github.com/soedinglab/hh-suite.git && \
    mkdir -p hh-suite/build && cd hh-suite/build && \
    cmake -DCMAKE_INSTALL_PREFIX=. .. && \
    make -j"$(nproc)" && make install && \
    cd ../..

# 7) Default to bash for manual testing
ENTRYPOINT ["bash"]

