FROM ubuntu:24.04

ARG HAMLIB_VERSION=4.6.5
ARG WSJTX_VERSION=2.7

ENV TZ='America/New_York'
RUN echo $TZ > /etc/timezone && \
  apt-get update && apt-get upgrade -y && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata && \
  rm /etc/localtime && \
  ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
  dpkg-reconfigure -f noninteractive tzdata && \
  apt-get install -y autoconf automake libtool cmake git wget less && \
  apt-get clean
RUN apt-get install -y \
    build-essential \
    gfortran \
    asciidoctor \
    libfftw3-dev \
    qtdeclarative5-dev \
    texinfo \
    libqt5multimedia5 \
    libqt5multimedia5-plugins \
    qtmultimedia5-dev \
    libusb-1.0.0-dev \
    libqt5serialport5-dev \
    qttools5-dev \
    asciidoc \
    libudev-dev \
    libboost-dev \
    libboost-log-dev

RUN mkdir /hamlib 
WORKDIR /hamlib
#RUN wget https://github.com/Hamlib/Hamlib/releases/download/4.6.5/hamlib-4.6.5.tar.gz
RUN wget https://github.com/Hamlib/Hamlib/releases/download/$HAMLIB_VERSION/hamlib-$HAMLIB_VERSION.tar.gz
RUN tar xf hamlib-$HAMLIB_VERSION.tar.gz
# RUN git clone --depth=1 https://github.com/Hamlib/Hamlib.git src
# RUN cd src && ./bootstrap && mkdir ../build && cd ../build && \
# ../src/configure --prefix=$HOME/hamlib-prefix    --disable-shared --enable-static    --without-cxx-binding --disable-winradio    CFLAGS="-g -O2 -fdata-sections -ffunction-sections"  LDFLAGS="-Wl,--gc-sections" && \
# make -j4 &&  make install-strip && cd ../../

WORKDIR /hamlib/hamlib-$HAMLIB_VERSION
RUN  ./configure && \
 make && \
 make install

RUN mkdir /wsjtx
WORKDIR /wsjtx
RUN git clone -b wsjtx-$WSJTX_VERSION --depth=1 https://git.code.sf.net/p/wsjt/wsjtx wsjt-wsjtx 
RUN mkdir build && mkdir output && cd build && cmake -D CMAKE_PREFIX_PATH=~/hamlib-prefix -D CMAKE_INSTALL_PREFIX=/wsjtx/output ../wsjt-wsjtx/ &&  cmake --build . -- -j4 && cmake --build . --target install

# add alsa tools
RUN apt update && \
    apt install -y  libasound2-dev alsa-utils


