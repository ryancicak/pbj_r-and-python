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


ENV PYTHON3_VERSION=3.10 \
   ML_RUNTIME_KERNEL="R 4.0" \
   ML_RUNTIME_EDITION=Standard \
   ML_RUNTIME_DESCRIPTION="Runtime with a custom PBJ with R installed (python by default) for GPU"

ENV ML_RUNTIME_EDITOR="PBJ Workbench" \
   ML_RUNTIME_EDITION="Tech Preview" \
   ML_RUNTIME_KERNEL="R 4.0" \
   ML_RUNTIME_JUPYTER_KERNEL_NAME="r4.0" \
   ML_RUNTIME_JUPYTER_KERNEL_GATEWAY_CMD="jupyter kernelgateway --config=/home/cdsw/.jupyter/jupyter_kernel_gateway_config.py --debug" \
   ML_RUNTIME_DESCRIPTION="Custom PBJ Workbench R runtime provided by Ryan" \
   JUPYTERLAB_WORKSPACES_DIR=/tmp

RUN \
    /bin/bash -c "echo -e \"install.packages('IRkernel')\nIRkernel::installspec(prefix='/usr/local',name = '${ML_RUNTIME_JUPYTER_KERNEL_NAME}', displayname = '${ML_RUNTIME_KERNEL}')\" | R --no-save" && \
    rm -rf /build

ENV \
   ML_RUNTIME_METADATA_VERSION=2 \
   ML_RUNTIME_FULL_VERSION=1.1.1 \
   ML_RUNTIME_SHORT_VERSION=1.1 \
   ML_RUNTIME_MAINTENANCE_VERSION=1 \
   ML_RUNTIME_GIT_HASH=0 \
   ML_RUNTIME_GBN=0

LABEL \
   com.cloudera.ml.runtime.runtime-metadata-version=$ML_RUNTIME_METADATA_VERSION \
   com.cloudera.ml.runtime.editor=$ML_RUNTIME_EDITOR \
   com.cloudera.ml.runtime.edition=$ML_RUNTIME_EDITION \
   com.cloudera.ml.runtime.description=$ML_RUNTIME_DESCRIPTION \
   com.cloudera.ml.runtime.kernel=$ML_RUNTIME_KERNEL \
   com.cloudera.ml.runtime.full-version=$ML_RUNTIME_FULL_VERSION \
   com.cloudera.ml.runtime.short-version=$ML_RUNTIME_SHORT_VERSION \
   com.cloudera.ml.runtime.maintenance-version=$ML_RUNTIME_MAINTENANCE_VERSION \
   com.cloudera.ml.runtime.git-hash=$ML_RUNTIME_GIT_HASH \
   com.cloudera.ml.runtime.gbn=$ML_RUNTIME_GBN \
   com.cloudera.ml.runtime.cuda-version=$ML_RUNTIME_CUDA_VERSION
