FROM ubuntu:18.04
MAINTAINER Raghav Gupta <raghavg96@gmail.com>
RUN apt-get update && apt-get install -y software-properties-common 
RUN apt-get install -y g++ gcc gdb libc6-dbg gdb valgrind
RUN apt-get install -y vim git cmake tmux screen

ARG INSTALL_LOCATION='/usr/local'
ARG SETUP_LOCATION='/tmp/setup'
ARG CPU_CORE=4

RUN mkdir -p ${INSTALL_LOCATION}

ARG OPENCV_REPO='https://github.com/opencv/opencv.git'
ARG OPENCV_CHECKOUT='3.4'

ARG OPENCV_SETUP_PATH=${SETUP_LOCATION}'/OPENCV'
RUN apt-get install -y libssl-dev && \
    git clone ${OPENCV_REPO} ${OPENCV_SETUP_PATH} && \
    cd ${OPENCV_SETUP_PATH} && git checkout ${OPENCV_CHECKOUT} && git submodule update --init --recursive && \
    mkdir -p ./cmake_build && cd ./cmake_build && \
    cmake .. -DCMAKE_INSTALL_PREFIX=${INSTALL_LOCATION} && \
    make -j${CPU_CORE} && \
    make install && \
    ldconfig && \
    rm -rf ${OPENCV_SETUP_PATH}

RUN apt-get install -y \
	autoconf \
	autoconf-archive \
	automake \
	build-essential \
	checkinstall \
	libcairo2-dev \
	libicu-dev \
	libjpeg-dev \
	libpango1.0-dev \
	libgif-dev \
	libwebp-dev \
	libopenjp2-7-dev \
	libpng-dev \
	libtiff-dev \
	libtool \
	pkg-config \
	wget \
	xzgv \
	zlib1g-dev

ENV BASE_DIR /home/workspace
ENV LEP_SRC_DIR ${BASE_DIR}/leptonica
ENV LEP_REPO_URL https://github.com/DanBloomberg/leptonica.git
ENV TES_SRC_DIR ${BASE_DIR}/tesseract
ENV TES_REPO_URL https://github.com/tesseract-ocr/tesseract.git
ENV TESSDATA_PREFIX /usr/local/share/tessdata

ARG TESSERACT_CHECKOUT='75103040c94ffd7fe5e4e3dfce0a7e67a8420849'
ARG LEPTONICA_CHECKOUT='1.78.0'
RUN mkdir ${BASE_DIR}
RUN mkdir ${TESSDATA_PREFIX}

RUN git clone ${LEP_REPO_URL} ${LEP_SRC_DIR} && \
    cd ${LEP_SRC_DIR} && git checkout ${LEPTONICA_CHECKOUT} && \ 
    mkdir -p ./cmake_build && cd ./cmake_build && \
    cmake .. -DCMAKE_INSTALL_PREFIX=${INSTALL_LOCATION} && \
    make -j${CPU_CORE} && \
    make install && \
    ldconfig

RUN git clone ${TES_REPO_URL} ${TES_SRC_DIR} && \
    cd ${TES_SRC_DIR} && git checkout ${TESSERACT_CHECKOUT} 

# osd	Orientation and script detection
RUN wget -O ${TESSDATA_PREFIX}/osd.traineddata https://github.com/tesseract-ocr/tessdata/raw/3.04.00/osd.traineddata

# equ	Math / equation detection
RUN wget -O ${TESSDATA_PREFIX}/equ.traineddata https://github.com/tesseract-ocr/tessdata/raw/3.04.00/equ.traineddata

# eng English
RUN wget -O ${TESSDATA_PREFIX}/eng.traineddata https://github.com/tesseract-ocr/tessdata/raw/4.00/eng.traineddata
    
WORKDIR /home


