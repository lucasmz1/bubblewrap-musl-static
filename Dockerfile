# Usa a versão mais recente do branch de desenvolvimento
FROM alpine:edge

RUN echo https://dl-cdn.alpinelinux.org/alpine/edge/main/ > /etc/apk/repositories && \
    echo https://dl-cdn.alpinelinux.org/alpine/edge/community/ >> /etc/apk/repositories && \
    echo http://dl-cdn.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories

# Instalação de todas as dependências de compilação
RUN apk update && apk add --no-cache \
    git gcc make musl-dev autoconf automake libtool ninja \
    linux-headers bash meson cmake pkgconfig \
    libcap-static libcap-dev \
    libselinux-static libselinux-dev \
    pcre2-static pcre2-dev \
    libxslt upx bash bash-completion \
    build-base

# Clona o repositório principal
RUN git clone https://github.com/containers/bubblewrap /bubblewrap
WORKDIR /bubblewrap

# CORREÇÃO CRÍTICA: Injeta os cabeçalhos necessários para compatibilidade com a musl libc
RUN sed -i '1i #include <linux/types.h>\n#include <limits.h>' utils.h

# Configura o diretório de build usando o Meson
RUN meson setup build

# Compila apenas os objetos necessários
RUN ninja -C build bwrap.p/bubblewrap.c.o bwrap.p/bind-mount.c.o bwrap.p/network.c.o bwrap.p/utils.c.o

WORKDIR /bubblewrap/build

# Faz a linkagem estática manual usando as flags corretas do pkg-config
RUN cc -o bwrap \
    bwrap.p/bubblewrap.c.o \
    bwrap.p/bind-mount.c.o \
    bwrap.p/network.c.o \
    bwrap.p/utils.c.o \
    -static $(pkg-config --static --libs libselinux libcap)

# Reduz o tamanho do binário removendo símbolos desnecessários
RUN strip -s -R .comment -R .gnu.version --strip-unneeded bwrap
# Usa a versão mais recente do branch de desenvolvimento
FROM alpine:edge

RUN echo https://dl-cdn.alpinelinux.org/alpine/edge/main/ > /etc/apk/repositories
RUN echo https://dl-cdn.alpinelinux.org/alpine/edge/community/ >> /etc/apk/repositories
RUN echo http://dl-cdn.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories

# Removemos as linhas que forçavam a v3.20. 
# O Alpine Edge já utiliza os repositórios 'edge' por padrão.
RUN apk update && apk add --no-cache \
    git gcc make musl-dev autoconf automake libtool ninja \
    linux-headers bash meson cmake pkgconfig \
    libcap-static libcap-dev \
    libselinux-static libselinux-dev \
    pcre2-static pcre2-dev \
    libxslt upx bash bash-completion \
    build-base
RUN source /etc/profile
RUN git clone --branch v0.12.0 https://github.com/containers/bubblewrap
WORKDIR /bubblewrap

RUN sed -i '1i #include <linux/types.h>\n#include <limits.h>' utils.h

RUN meson setup build
RUN ninja -C build bwrap.p/bubblewrap.c.o bwrap.p/bind-mount.c.o bwrap.p/network.c.o bwrap.p/utils.c.o

WORKDIR /bubblewrap/build

# Mantivemos seu comando de linkagem manual. 
# Nota: certifique-se de que as dependências estáticas do selinux existam no edge.
# O pkg-config --static --libs libselinux libcap dirá ao compilador 
# exatamente quais arquivos .a e flags são necessários.
RUN cc -o bwrap \
    bwrap.p/bubblewrap.c.o \
    bwrap.p/bind-mount.c.o \
    bwrap.p/network.c.o \
    bwrap.p/utils.c.o \
    -static $(pkg-config --static --libs libselinux libcap)

# Strip
RUN strip -s -R .comment -R .gnu.version --strip-unneeded bwrap

# Compressão (opcional)
# RUN upx --ultra-brute --no-lzma bwrapFROM alpine:latest

RUN apk update && apk add --no-cache \
    git gcc make musl-dev autoconf automake libtool ninja \
    linux-headers bash meson cmake pkgconfig \
    libcap-static libcap-dev \
    libselinux-static libselinux-dev \
    pcre2-static pcre2-dev \
    libxslt upx bash bash-completion \
    build-base
RUN source /etc/profile
RUN git clone --branch v0.12.0 https://github.com/containers/bubblewrap
WORKDIR /bubblewrap

RUN sed -i '1i #include <linux/types.h>\n#include <limits.h>' utils.h

RUN meson build

RUN ninja -C build bwrap.p/bubblewrap.c.o bwrap.p/bind-mount.c.o bwrap.p/network.c.o bwrap.p/utils.c.o

WORKDIR build

# O pkg-config --static --libs libselinux libcap dirá ao compilador 
# exatamente quais arquivos .a e flags são necessários.
RUN cc -o bwrap \
    bwrap.p/bubblewrap.c.o \
    bwrap.p/bind-mount.c.o \
    bwrap.p/network.c.o \
    bwrap.p/utils.c.o \
    -static $(pkg-config --static --libs libselinux libcap)

# Strip
RUN strip -s -R .comment -R .gnu.version --strip-unneeded bwrap

# Compress
# RUN upx --ultra-brute --no-lzma bwrap
