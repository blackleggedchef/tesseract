FROM ubuntu:18.04
MAINTAINER Raghav Gupta <raghavg96@gmail.com>
RUN apt-get update && apt-get install -y software-properties-common 
RUN apt-get install -y g++ gcc gdb libc6-dbg gdb valgrind
RUN apt-get install -y vim git cmake tmux screen python

ARG INSTALL_LOCATION='/usr/local'
ARG SETUP_LOCATION='/tmp/setup'
ARG CPU_CORE=4

RUN mkdir -p ${INSTALL_LOCATION}

ARG G3LOG_REPO='https://github.com/KjellKod/g3log.git'
ARG G3LOG_CHECKOUT='tags/1.3.2'
ARG OPENCV_REPO='https://github.com/opencv/opencv.git'
ARG OPENCV_CHECKOUT='3.4'

#install openCV
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

# install g3log
ARG G3LOG_SETUP_PATH=${SETUP_LOCATION}'/G3LOG'
RUN apt-get install -y libjsoncpp-dev autoconf automake libtool curl make g++ unzip && \
    git clone ${G3LOG_REPO} ${G3LOG_SETUP_PATH} && \
    cd ${G3LOG_SETUP_PATH} && git checkout ${G3LOG_CHECKOUT} && git submodule update --init --recursive && \
    cd 3rdParty/gtest && unzip -u -o gtest-1.7.0.zip && cd ../../ && \
    mkdir -p ./cmake_build && cd ./cmake_build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release -DCPACK_PACKAGING_INSTALL_PREFIX=${INSTALL_LOCATION} && \
    make -j${CPU_CORE} package && \
    make install && \
    ldconfig && \
    rm -rf ${G3LOG_SETUP_PATH}


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


ENV TESSDATA_PREFIX /usr/local/share/tessdata
RUN mkdir ${TESSDATA_PREFIX}


# osd	Orientation and script detection
RUN wget -O ${TESSDATA_PREFIX}/osd.traineddata https://github.com/tesseract-ocr/tessdata/raw/3.04.00/osd.traineddata

# equ	Math / equation detection
RUN wget -O ${TESSDATA_PREFIX}/equ.traineddata https://github.com/tesseract-ocr/tessdata/raw/3.04.00/equ.traineddata

# eng English
RUN wget -O ${TESSDATA_PREFIX}/eng.traineddata https://github.com/tesseract-ocr/tessdata/raw/4.00/eng.traineddata
    
WORKDIR /home


