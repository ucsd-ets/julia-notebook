# 1) choose base container
# generally use the most recent tag

# base notebook, contains Jupyter and relevant tools
# See https://github.com/ucsd-ets/datahub-docker-stack/wiki/Stable-Tag 
# for a list of the most current containers we maintain
ARG BASE_CONTAINER=ghcr.io/ucsd-ets/datascience-notebook:stable

FROM $BASE_CONTAINER

LABEL maintainer="UC San Diego ITS/ETS <ets-consult@ucsd.edu>"

# 2) change to root to install packages
USER root

RUN apt-get -y install htop

# uninstall old julia
RUN rm -rf /opt/julia* && rm /usr/local/bin/julia && rm -rf /etc/julia

ENV JULIA_VERSION=1.9.3
ENV JULIA_DEPOT_PATH=/opt/julia \
    JULIA_PKGDIR=/opt/julia

# Setup Julia
COPY setup-julia.bash /opt/setup-scripts/setup-julia.bash
COPY setup-julia-packages.bash /opt/setup-scripts/setup-julia-packages.bash
RUN chmod +x /opt/setup-scripts/setup-julia.bash && /opt/setup-scripts/setup-julia.bash
RUN chmod +x /opt/setup-scripts/setup-julia-packages.bash

RUN chmod 777 /opt/julia -R && chmod 777 /opt/julia-1.9.3 -R
RUN chmod g+s /opt/julia && chmod g+s /opt/julia-1.9.3

# 3) install packages using notebook user
USER jovyan

ENV JULIA_DEPOT_PATH=/opt/julia JULIA_PKGDIR=/opt/julia
RUN mkdir /opt/julia/logs
RUN chmod 1777 /opt/julia/logs

RUN /opt/setup-scripts/setup-julia-packages.bash
# RUN conda install -y scikit-learn

RUN pip install --no-cache-dir networkx scipy

RUN chmod -R o+w /opt/julia
ENV JULIA_DEPOT_PATH=~/.julia:/opt/julia

# Override command to disable running jupyter notebook at launch
# CMD ["/bin/bash"]
