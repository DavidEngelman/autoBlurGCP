ARG BASE_IMAGE=nvidia/cuda:10.0-cudnn7-devel
FROM $BASE_IMAGE

ENV DEBIAN_FRONTEND noninteractive

ARG ADDITIONAL_PACKAGES=""

RUN apt-get update \
      && apt-get install --no-install-recommends --no-install-suggests -y gnupg2 ca-certificates \
            git build-essential $ADDITIONAL_PACKAGES \
      && rm -rf /var/lib/apt/lists/*

COPY configure.sh /tmp/

ARG SOURCE_BRANCH=unspecified
ENV SOURCE_BRANCH $SOURCE_BRANCH

ARG SOURCE_COMMIT=unspecified
ENV SOURCE_COMMIT $SOURCE_COMMIT

ARG CONFIG

# Get and build darknet
RUN git clone https://github.com/DavidEngelman/autoBlur.git && cd autoBlur/darknet \
      && /tmp/configure.sh $CONFIG && make \
      && cp darknet /usr/local/bin \
      && cd .. && rm -rf darknet

# Heads dataset
RUN wget https://www.di.ens.fr/willow/research/headdetection/release/head.zip \
    && unzip head.zip \
    && mv head autoBlur/darknet/build/darknet/x64/data

# Tiny yolov4 weights
RUN wget https://github.com/AlexeyAB/darknet/releases/download/darknet_yolo_v4_pre/yolov4-tiny.conv.29 \
    && mv yolov4-tiny.conv.29 autoBlur/darknet/build/darknet/x64

# Full yolov4 weights
RUN wget https://github.com/AlexeyAB/darknet/releases/download/darknet_yolo_v3_optimal/yolov4.conv.137 \
    && mv yolov4.conv.137 autoBlur/darknet/build/darknet/x64


