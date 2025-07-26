FROM ubuntu:latest
#RUN userdel -r ubuntu

ENV TZ='America/New_York'
RUN echo $TZ > /etc/timezone && \
  apt-get update && apt-get upgrade -y && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata && \
  rm /etc/localtime && \
  ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
  dpkg-reconfigure -f noninteractive tzdata && \
  apt-get install -y autoconf automake libtool cmake git && \
  apt-get clean
RUN apt-get install -y build-essential gfortran asciidoctor libfftw3-dev qtdeclarative5-dev texinfo libqt5multimedia5 libqt5multimedia5-plugins qtmultimedia5-dev libusb-1.0.0-dev libqt5serialport5-dev qttools5-dev asciidoc libudev-dev libboost-dev libboost-log-dev

RUN mkdir /hamlib 
WORKDIR /hamlib
RUN git clone --depth=1 https://github.com/Hamlib/Hamlib.git src
RUN cd src && ./bootstrap && mkdir ../build && cd ../build && \
 ../src/configure --prefix=$HOME/hamlib-prefix    --disable-shared --enable-static    --without-cxx-binding --disable-winradio    CFLAGS="-g -O2 -fdata-sections -ffunction-sections"  LDFLAGS="-Wl,--gc-sections" && \
 make -j4 &&  make install-strip && cd ../../

RUN mkdir /wsjtx
WORKDIR /wsjtx
RUN git clone --depth=1 https://git.code.sf.net/p/wsjt/wsjtx wsjt-wsjtx 
RUN mkdir build && mkdir output && cd build && cmake -D CMAKE_PREFIX_PATH=~/hamlib-prefix -D CMAKE_INSTALL_PREFIX=/wsjtx/output ../wsjt-wsjtx/ &&  cmake --build . -- -j4 && cmake --build . --target install

# add alsa tools
RUN apt update && \
    apt install -y  libasound2-dev alsa-utils

# RUN groupadd -g 1000 user
# RUN useradd -ms /bin/bash -u 1000 -g user user
# RUN usermod -a -G audio user
# RUN usermod -a -G dialout user
# RUN usermod -a -G plugdev user
# RUN install -d -m 0755 -o user -g user /home/user
# RUN chown --changes --silent --no-dereference --recursive 1000:1000 /home/user
# USER user
# CMD ["/bin/bash"]
