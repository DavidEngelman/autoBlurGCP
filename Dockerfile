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