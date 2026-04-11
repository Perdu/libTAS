FROM debian:12 AS ruffle-builder

  # Dependencies
    RUN apt-get update && apt-get install -y \
          git \
          pkg-config \
          libasound2-dev \
          libudev-dev \
          default-jre-headless \
          g++ \
          curl
    RUN curl https://sh.rustup.rs -sSf | sh -s -- -y

  # Installs
    RUN mkdir /root/src
    # pin version
    # ARG RUFFLE_VERSION=fa9c6627bd86511de1b710dcf42708dc55c44e3e
    ARG RUFFLE_VERSION=""
    RUN cd /root/src && git clone https://github.com/ruffle-rs/ruffle.git && cd ruffle && git checkout $RUFFLE_VERSION
    WORKDIR /root/src/ruffle
    ENV PATH="/root/.cargo/bin:${PATH}"
    RUN cargo build --release --package=ruffle_desktop


FROM debian:12 AS pcem-builder

  # Dependencies
    RUN apt-get update && apt-get install -y \
        git \
        build-essential \
        automake \
        pkg-config \
        libwxbase3.2 \
        libwxgtk3.2 \
        wx-common \
        libsdl2-dev \
        libopenal-dev

  # Install
    RUN mkdir /root/src
    # ARG PCEM_VERSION=v16_9b737f6
    ARG PCEM_VERSION=""
    RUN cd /root/src && git clone https://github.com/TASVideos/pcem.git
    RUN cd /root/src/pcem && autoreconf -i
    RUN cd /root/src/pcem && ./configure --enable-release-build
    RUN cd /root/src/pcem && make


FROM debian:12 AS libtas-builder

  RUN dpkg --add-architecture i386

  # Dependencies
      RUN apt-get update && apt-get -y install \
    # build tools
      git wget build-essential automake pkg-config \
    # main
      libx11-dev libx11-xcb-dev qtbase5-dev libsdl2-dev libxcb1-dev libxcb-keysyms1-dev libxcb-xkb-dev libxcb-cursor-dev libxcb-randr0-dev libudev-dev libasound2-dev libavutil-dev libswresample-dev ffmpeg liblua5.4-dev libcap-dev libxcb-xinput-dev \
    # HUD
      libfreetype6-dev libfontconfig1-dev \
    # fonts
      libfreetype6-dev libfontconfig1-dev \
      fonts-liberation \
    # i386
      g++-multilib \
      libx11-6:i386 libx11-dev:i386 libx11-xcb1:i386 libx11-xcb-dev:i386 libasound2:i386 libasound2-dev:i386 libavutil57:i386 libswresample4:i386 libfreetype6:i386 libfreetype6-dev:i386 libfontconfig1:i386 libfontconfig1-dev:i386

  # Installs
    RUN mkdir /root/src
    # RUN cd /root/src && git clone https://github.com/clementgallet/libTAS.git
    # ARG LIBTAS_VERSION=a6748b4f0c943fc1fc4b71c74b51b3be8aac0ac8
    ARG LIBTAS_VERSION=""
    RUN cd /root/src && git clone https://github.com/Perdu/libTAS.git && cd /root/src/libTAS && git checkout $LIBTAS_VERSION
    WORKDIR /root/src/libTAS
    # RUN git fetch origin pull/667/head:pr-667 && git checkout pr-667
    # RUN git checkout v1.4.7
    RUN ./build.sh --with-i386
    RUN cd ./build && make install


FROM debian:12-slim

  RUN apt-get update && apt-get install -y \
  # pcem
    libopenal1 \
    libwxgtk3.2 \
    libsdl2-2.0-0 \
  # ruffle
    libasound2 \
    file \
  # libTAS
    libqt5widgets5 \
    libqt5gui5 \
    libqt5core5a \
    libqt5network5 \
    libqt5x11extras5 \
    liblua5.4-0 \
  # util
    xvfb

  COPY --from=pcem-builder /root/src/pcem/pcem /usr/local/bin/pcem
  COPY --from=ruffle-builder /root/src/ruffle/target/release/ruffle_desktop /usr/local/bin/ruffle_desktop
  COPY --from=libtas-builder /root/src/libTAS/build/AppDir/usr/bin/libTAS /usr/local/bin/libTAS
  COPY --from=libtas-builder /root/src/libTAS/build/AppDir/usr/bin/libtas.so /usr/local/bin/libtas.so
  COPY --from=libtas-builder /root/src/libTAS/build/AppDir/usr/bin/libtas32.so /usr/local/bin/libtas32.so

  # run
    CMD bash
