FROM    crukcibioinformatics/alignment:4.1.0

LABEL   maintainer="Richard Bowers<richard.bowers@cruk.cam.ac.uk>"

ARG INSTALL_DIR=/opt
ARG BUILD_DIR=/var/tmp/mga_referencebuilder_software_build

ARG BOWTIE1_V=1.3.1

ARG TAROPTS="--no-same-owner --no-same-permissions"

RUN dnf install -y python3 python3-urllib3 python3-openpyxl

RUN mkdir -p ${INSTALL_DIR} ${BUILD_DIR}

# Bowtie 1
RUN cd ${BUILD_DIR}; \
    wget https://downloads.sourceforge.net/project/bowtie-bio/bowtie/${BOWTIE1_V}/bowtie-${BOWTIE1_V}-linux-x86_64.zip
RUN cd ${INSTALL_DIR}; \
    unzip -q ${BUILD_DIR}/bowtie-${BOWTIE1_V}-linux-x86_64.zip && \
    mv bowtie-${BOWTIE1_V}-linux-x86_64 bowtie-${BOWTIE1_V}

# This pipeline's Java programs.
COPY mga-referencebuilder.jar /usr/local/lib

## Clean up
RUN cd / && rm -rf ${BUILD_DIR}
