FROM    crukcibioinformatics/alignment:4.0.5

LABEL   maintainer="Richard Bowers<richard.bowers@cruk.cam.ac.uk>"

ARG INSTALL_DIR=/opt
ARG BUILD_DIR=/var/tmp/mga_referencebuilder_software_build

ARG BOWTIE1=1.1.1

ARG TAROPTS="--no-same-owner --no-same-permissions"

RUN dnf install -y java-17-openjdk-devel python3 python3-urllib3 python3-openpyxl

RUN mkdir -p ${INSTALL_DIR} ${BUILD_DIR}

# Bowtie 1
RUN cd ${BUILD_DIR}; \
    wget https://downloads.sourceforge.net/project/bowtie-bio/bowtie/${BOWTIE1}/bowtie-${BOWTIE1}-linux-x86_64.zip
RUN cd ${INSTALL_DIR}; \
    unzip -q ${BUILD_DIR}/bowtie-${BOWTIE1}-linux-x86_64.zip

# This pipeline's Java programs.
COPY nf-referencebuilder.jar /opt

## Clean up
RUN cd / && rm -rf ${BUILD_DIR}
