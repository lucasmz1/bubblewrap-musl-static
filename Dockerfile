# ==========================================
# ETAPA 1: Compilação (Ambiente de Build Estável)
# ==========================================
FROM alpine:3.24 AS builder2

# Instala as dependências de compilação diretamente da versão estável v3.24
RUN apk update && apk add --no-cache \
    wget \
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
    pcre2-dev \
    build-base

# Clona a versão estável v0.12.0 do Bubblewrap (Sem espaços incorretos na URL)
#RUN git clone --branch v0.11.0 https://github.com/containers/bubblewrap /bubblewrap2
RUN wget -q https://github.com/containers/bubblewrap/archive/refs/tags/v0.12.0.zip && mkdir /bubblewrap2 && unzip v0.12.0.zip -d /bubblewrap2
WORKDIR /bubblewrap2/bubblewrap-0.12.0

# Configura o Meson injetando a flag para linkagem estática nativa
RUN LDFLAGS="-static" meson setup build \
    --buildtype=release \
    -Ddefault_library=static \
    -Dtests=false

# O próprio Meson compila tudo de forma limpa e automática para qualquer arquitetura
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
