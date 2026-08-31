FROM alpine:latest

# Update repositories
RUN echo https://dl-cdn.alpinelinux.org/alpine/v3.24/main/ > /etc/apk/repositories
RUN echo https://dl-cdn.alpinelinux.org/alpine/v3.24/community/ >> /etc/apk/repositories

RUN apk update
RUN apk add --no-cache git gcc make musl-dev autoconf automake libtool ninja \
  linux-headers bash meson cmake pkgconfig libcap-static libcap-dev \
  libselinux-dev libxslt upx build-base

RUN apk add --no-cache \
    libselinux-dev \
    libselinux-static \
    libcap-dev \
    libcap-static
  
RUN git clone --depth 1 --branch v0.12.0 https://github.com/containers/bubblewrap.git

WORKDIR bubblewrap

RUN sed -i '1i #include <limits.h>' bubblewrap.c

RUN meson setup build -Dprefer_static=true

RUN ninja -C build

WORKDIR build

RUN cc -o bwrap bwrap.p/bubblewrap.c.o bwrap.p/bind-mount.c.o bwrap.p/network.c.o bwrap.p/utils.c.o -static -L/usr/lib -lcap -lselinux

# Strip
RUN strip -s -R .comment -R .gnu.version --strip-unneeded bwrap

# Compress
# RUN upx --ultra-brute --no-lzma bwrap
