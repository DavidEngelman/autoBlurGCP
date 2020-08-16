ARG BASE_IMAGE=nvidia/cuda:10.0-cudnn7-devel
FROM $BASE_IMAGE

ENV DEBIAN_FRONTEND noninteractive

ARG ADDITIONAL_PACKAGES=""

RUN apt-get update \
      && apt-get install --no-install-recommends --no-install-suggests -y gnupg2 ca-certificates \
            git build-essential $ADDITIONAL_PACKAGES \
      && rm -rf /var/lib/apt/lists/*


ARG SOURCE_BRANCH=unspecified
ENV SOURCE_BRANCH $SOURCE_BRANCH

ARG SOURCE_COMMIT=unspecified
ENV SOURCE_COMMIT $SOURCE_COMMIT

ARG CONFIG

COPY configure.sh /tmp/ 
RUN sed -i -e 's/\r$//' /tmp/configure.sh

RUN chmod +x /tmp/configure.sh

# Get and build darknet
RUN git clone https://github.com/DavidEngelman/autoBlur.git && cd autoBlur/darknet \
      && bash /tmp/configure.sh $CONFIG && make \
      && cp darknet /usr/local/bin \
      && cd ../..

RUN apt-get update -y && apt-get upgrade -y
RUN apt-get install -y unzip
RUN apt-get install -y wget

# Tiny yolov4 weights
RUN wget https://github.com/AlexeyAB/darknet/releases/download/darknet_yolo_v4_pre/yolov4-tiny.conv.29 \
    && mv yolov4-tiny.conv.29 autoBlur/darknet/build/darknet/x64

# Full yolov4 weights
RUN wget https://github.com/AlexeyAB/darknet/releases/download/darknet_yolo_v3_optimal/yolov4.conv.137 \
    && mv yolov4.conv.137 autoBlur/darknet/build/darknet/x64

# Heads dataset
# RUN wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=1NvxKyLvsh-I6JQSewipR04VdrSMS0RaG' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=1NvxKyLvsh-I6JQSewipR04VdrSMS0RaG" -O head.zip && rm -rf /tmp/cookies.txt
RUN unzip head.zip
RUN mv head autoBlur/darknet/build/darknet/x64/data

