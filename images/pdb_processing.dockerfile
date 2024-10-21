FROM ubuntu:18.04

LABEL version="0.1"
LABEL maintainer="Miles Thorburn <miles@resurrect.bio>"
LABEL description="Dockerfile for AF2 post-processing"

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
    && conda config --add channels r \
    && conda init --all

ADD ./af_distances.tar.gz /usr/local/src
WORKDIR /usr/local/src
RUN conda env create -f /usr/local/src/af_distance/environment.yml
ENV PATH "/opt/conda/envs/af_distances/bin:/usr/local/src/af_distance:$PATH"
WORKDIR /usr/local/src/af_distance
