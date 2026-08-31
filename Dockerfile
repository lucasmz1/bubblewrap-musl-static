# ==========================================
# ETAPA 1: Compilação (Ambiente de Build Estável)
# ==========================================
FROM alpine:3.24 AS builder2

# Instala as dependências de compilação diretamente da versão estável v3.24
RUN apk update && apk add --no-cache \
    wget \
    unzip \
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

# Baixa e extrai o código fonte da tag v0.12.0 de forma limpa
RUN wget -q https://github.com && \
    mkdir /bubblewrap2 && \
    unzip v0.12.0.zip -d /bubblewrap2 && \
    rm v0.12.0.zip

WORKDIR /bubblewrap2/bubblewrap-0.12.0

# Injeta os arquivos de cabeçalho necessários para a musl libc do Alpine v3.24
RUN sed -i '1i #include <linux/types.h>\n#include <limits.h>' utils.h

# CORREÇÃO DEFINITIVA: Desativamos a detecção automática do SELinux pelo Meson 
# e injetamos os parâmetros estáticos e bibliotecas (.a) manualmente para evitar o link dinâmico (.so).
RUN meson setup build \
    --buildtype=release \
    -Ddefault_library=static \
    -Dtests=false \
    -Dselinux=disabled \
    -Dc_link_args="-static -lcap"

# Compila o projeto de forma nativa e automatizada
RUN meson compile -C build

WORKDIR /bubblewrap2/bubblewrap-0.12.0/build

# Remove metadados do binário final para reduzir o tamanho
RUN strip -s -R .comment -R .gnu.version --strip-unneeded bwrap


# ==========================================
# ETAPA 2: Imagem Final Otimizada e Segura
# ==========================================
FROM alpine:3.24

# Transfere apenas o binário executável estático gerado na etapa anterior
COPY --from=builder2 /bubblewrap2/bubblewrap-0.12.0/build/bwrap /usr/local/bin/bwrap

# Define o ponto de entrada do container
ENTRYPOINT ["/usr/local/bin/bwrap"]
