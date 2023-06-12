FROM nvidia/cuda:10.0-cudnn7-devel-ubi7

LABEL maintainer="Condados"
LABEL version="v0.1.0"
LABEL description="Base Image for Tensorflow 1.15 and Python 3.7 with GPU on RedHat Linux 8"

RUN yum update -y && yum install -y \
        wget           \
        gcc            \
        openssl-devel  \
        bzip2-devel    \
        libffi-devel   \
        zlib-devel     \
        xz-devel

RUN cd /usr/src \
    && wget https://www.python.org/ftp/python/3.7.11/Python-3.7.11.tgz \
    && tar xzf Python-3.7.11.tgz \
    && cd Python-3.7.11 \
    && ./configure --enable-optimizations \
    && make altinstall \
    && rm /usr/src/Python-3.7.11.tgz

## Create mount point for workspace
RUN mkdir /workspace
RUN chmod -R a+rwx /workspace
WORKDIR /workspace

# Here we get all python packages.
# There's substantial overlap between scipy and numpy that we eliminate by
# linking them together. Likewise, pip leaves the install caches populated which uses
# a significant amount of space. These optimizations save a fair amount of space in the
# image, which reduces start up time.

COPY ./requirements.txt /workspace/requirements.txt

# Install pip packages
RUN python3.7 -m pip install --upgrade pip

RUN pip3.7 install tensorflow-gpu==1.15 protobuf==3.19

RUN pip3.7 install --no-cache-dir --upgrade -r /workspace/requirements.txt

# Set some environment variables. PYTHONUNBUFFERED keeps Python from buffering our standard
# output stream, which means that logs can be delivered to the user quickly. PYTHONDONTWRITEBYTECODE
# keeps Python from writing the .pyc files which are unnecessary in this case. We also update
# PATH so that the serve program are found when the container is invoked.

ENV PYTHONUNBUFFERED=TRUE
ENV PYTHONDONTWRITEBYTECODE=TRUE
ENV PATH="/workspace:${PATH}"
# Configure python path for custom modules
ENV PYTHONPATH "${PYTHONPATH}:/workspace"

# Configure default shell
ENV SHELL=/bin/bash