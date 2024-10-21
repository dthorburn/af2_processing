FROM ubuntu:18.04

LABEL version="0.1"
LABEL maintainer="Miles Thorburn <miles@resurrect.bio>"
LABEL description="Dockerfile for python AF2 post-processing"

ARG DEBIAN_FRONTEND=noninteractive

## Setting up basics
RUN apt-get -y update \
    && apt-get install -y --no-install-recommends build-essential gcc curl git rsync wget gnutls-bin \
    && apt-get clean

## Setting up conda
ENV CONDA_DIR /opt/conda
RUN wget --quiet --no-check-certificate https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda
ENV PATH=$CONDA_DIR/bin:$PATH
RUN conda config --add channels bioconda \
    && conda config --add channels conda-forge \
    && conda config --add channels anaconda \
    && conda init --all

WORKDIR /usr/local/src
## Installing necessary Python libraries
RUN conda install -y mdanalysis pandas numpy \
    && conda clean -afy

ENV PATH "/opt/conda/envs/pdb_contacts/bin:$PATH"

