# Usa a versão mais recente do branch de desenvolvimento
FROM alpine:edge

# Removemos as linhas que forçavam a v3.20. 
# O Alpine Edge já utiliza os repositórios 'edge' por padrão.
RUN apk update && apk add --no-cache \
    git gcc make musl-dev autoconf automake libtool ninja \
    linux-headers bash meson cmake pkgconfig libcap-static libcap-dev \
    libselinux-static \
    libsepol-static \
    libselinux-dev libxslt upx

RUN git clone https://github.com/ruanformigoni/bubblewrap
WORKDIR /bubblewrap

RUN meson setup build
RUN ninja -C build bwrap.p/bubblewrap.c.o bwrap.p/bind-mount.c.o bwrap.p/network.c.o bwrap.p/utils.c.o

WORKDIR /bubblewrap/build

# Mantivemos seu comando de linkagem manual. 
# Nota: certifique-se de que as dependências estáticas do selinux existam no edge.
RUN RUN cc -o bwrap \
    bwrap.p/bubblewrap.c.o \
    bwrap.p/bind-mount.c.o \
    bwrap.p/network.c.o \
    bwrap.p/utils.c.o \
    -static \
    $(pkg-config --static --libs libselinux libcap)

# Strip
RUN strip -s -R .comment -R .gnu.version --strip-unneeded bwrap

# Compressão (opcional)
# RUN upx --ultra-brute --no-lzma bwrapFROM alpine:latest

RUN apk update
RUN apk add --no-cache git gcc make musl-dev autoconf automake libtool ninja \
  linux-headers bash meson cmake pkgconfig libcap-static libcap-dev \
  libselinux-dev libxslt upx

RUN git clone https://github.com/ruanformigoni/bubblewrap

WORKDIR bubblewrap

RUN meson build

RUN ninja -C build bwrap.p/bubblewrap.c.o bwrap.p/bind-mount.c.o bwrap.p/network.c.o bwrap.p/utils.c.o

WORKDIR build

RUN cc -o bwrap bwrap.p/bubblewrap.c.o bwrap.p/bind-mount.c.o bwrap.p/network.c.o bwrap.p/utils.c.o -static -L/usr/lib -lcap -lselinux

# Strip
RUN strip -s -R .comment -R .gnu.version --strip-unneeded bwrap

# Compress
# RUN upx --ultra-brute --no-lzma bwrap
