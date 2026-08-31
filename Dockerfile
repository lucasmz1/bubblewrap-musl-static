# ==========================================
# ETAPA 1: Compilação (Ambiente de Build)
# ==========================================
FROM alpine:edge AS builder

# Configura os repositórios estáveis e de testes do Alpine Edge
RUN echo "https://alpinelinux.org" > /etc/apk/repositories && \
    echo "https://alpinelinux.org" >> /etc/apk/repositories && \
    echo "http://alpinelinux.org" >> /etc/apk/repositories

# Instalação explícita de dependências — build-base REMOVIDO
RUN apk update && apk add --no-cache \
    git \
    gcc \
    make \
    musl-dev \
    ninja \
    linux-headers \
    bash \
    meson \
    pkgconfig \
    libcap-static \
    libcap-dev \
    libselinux-static \
    libselinux-dev \
    pcre2-static \
    pcre2-dev

# Clona o código-fonte do Bubblewrap
RUN git clone https://github.com /bubblewrap
WORKDIR /bubblewrap

# Injeta os arquivos de cabeçalho necessários para a musl libc
RUN sed -i '1i #include <linux/types.h>\n#include <limits.h>' utils.h

# Configura o Meson injetando a flag para linkagem puramente estática
RUN LDFLAGS="-static" meson setup build \
    --buildtype=release \
    -Ddefault_library=static

# Compila o projeto de forma nativa e automatizada
RUN meson compile -C build

WORKDIR /bubblewrap/build

# O comando strip necessita do pacote binutils (instalado indiretamente por outras dependências),
# ele limpa os metadados desnecessários do binário final.
RUN strip -s -R .comment -R .gnu.version --strip-unneeded bwrap


# ==========================================
# ETAPA 2: Imagem Final Otimizada
# ==========================================
FROM alpine:edge

# Transfere apenas o binário executável estático e limpo
COPY --from=builder /bubblewrap/build/bwrap /usr/local/bin/bwrap

# Define o ponto de entrada do container
ENTRYPOINT ["/usr/local/bin/bwrap"]
