FROM docker.repository.cloudera.com/cloudera/cdsw/ml-runtime-pbj-workbench-python3.10-cuda:2023.05.2-b7

# Updated the images with apt-get
RUN apt-get update && apt-get upgrade -y

# Setup R Repos
RUN apt-get install -y --no-install-recommends software-properties-common dirmngr gdebi-core
RUN curl https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc > /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc
RUN add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/"

# Install R
# Since this Dockerfile uses the CML Python base image, it is necessary to install R. This will 
# not install the # cdsw package used for managing experiments and models with R sessions. Given 
# that models and # experiments don't use R-Studio as the editor, this is not a problem. Just make 
# sure to keep consistency in R versions. The current CML R Runtime uses R 4.0.4, so that is the 
# target version to install
RUN apt-get install -y r-base-core=4.0.4-1.2004.0

RUN \
    apt-get update && \
    cat /build/r-runtime-dependencies.txt | \
      sed '/^$/d; /^#/d; s/#.*$//' | \
      xargs apt-get install -y --no-install-recommends && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /build 

# Set the ENV and LABEL details for this Runtime
# The final requirement is to set various labels and environment variables that CML needs 
# to pick up the Runtime's details. Here the editor is to RStudio
ENV ML_RUNTIME_EDITOR="PBJ" \ 
ML_RUNTIME_EDITION="PBJ with R and Python"	\ 
ML_RUNTIME_SHORT_VERSION="2023.05" \
ML_RUNTIME_MAINTENANCE_VERSION="8" \
ML_RUNTIME_FULL_VERSION="2023.05.2" \
ML_RUNTIME_DESCRIPTION="PBJ with R and Python" \
ML_RUNTIME_KERNEL="R 4.0"

LABEL com.cloudera.ml.runtime.editor=$ML_RUNTIME_EDITOR \
com.cloudera.ml.runtime.edition=$ML_RUNTIME_EDITION \
com.cloudera.ml.runtime.full-version=$ML_RUNTIME_FULL_VERSION \
com.cloudera.ml.runtime.short-version=$ML_RUNTIME_SHORT_VERSION \
com.cloudera.ml.runtime.maintenance-version=$ML_RUNTIME_MAINTENANCE_VERSION \
com.cloudera.ml.runtime.description=$ML_RUNTIME_DESCRIPTION \
com.cloudera.ml.runtime.kernel=$ML_RUNTIME_KERNEL
