# ==========================================
# ETAPA 1: Compilação (Ambiente de Build Estável)
# ==========================================
FROM alpine:3.24 AS builder

# Instala as dependências de compilação diretamente dos repositórios estáveis da v3.20
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

# Clona a versão estável v0.10.0 do Bubblewrap (Garante que o código seja previsível)
RUN git clone --branch v0.10.0 https://github.com /bubblewrap
WORKDIR /bubblewrap

# Configura o Meson injetando a flag para linkagem puramente estática nativa
RUN LDFLAGS="-static" meson setup build \
    --buildtype=release \
    -Ddefault_library=static

# O próprio Meson gerencia e compila tudo de forma limpa e automática
RUN meson compile -C build

WORKDIR /bubblewrap/build

# Remove metadados do binário final para reduzir o tamanho
RUN strip -s -R .comment -R .gnu.version --strip-unneeded bwrap


# ==========================================
# ETAPA 2: Imagem Final Otimizada e Segura
# ==========================================
FROM alpine:3.20

# Transfere apenas o binário executável estático e limpo
COPY --from=builder /bubblewrap/build/bwrap /usr/local/bin/bwrap

# Define o ponto de entrada do container
ENTRYPOINT ["/usr/local/bin/bwrap"]
# ==========================================
# ETAPA 1: Compilação (Ambiente de Build)
# ==========================================
FROM alpine:edge AS builder

# Atualiza e instala as dependências apontando os repositórios diretamente no comando.
# Isso ignora os arquivos de configuração locais e evita erros de cache (build-base REMOVIDO).
RUN apk update --no-cache && apk add --no-cache \
    --repository=https://alpinelinux.org \
    --repository=https://alpinelinux.org \
    --repository=https://alpinelinux.org \
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

# Remove metadados do binário final
RUN strip -s -R .comment -R .gnu.version --strip-unneeded bwrap


# ==========================================
# ETAPA 2: Imagem Final Otimizada
# ==========================================
FROM alpine:edge

# Transfere apenas o binário executável estático e limpo
COPY --from=builder /bubblewrap/build/bwrap /usr/local/bin/bwrap

# Define o ponto de entrada do container
ENTRYPOINT ["/usr/local/bin/bwrap"]
# ==========================================
# ETAPA 1: Compilação (Ambiente de Build)
# ==========================================
FROM alpine:edge AS builder

# CORREÇÃO DEFINITIVA: Remove os links institucionais e insere apenas os espelhos de pacotes oficiais
RUN rm -f /etc/apk/repositories && \
    echo "https://alpinelinux.org" > /etc/apk/repositories && \
    echo "https://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    echo "https://alpinelinux.org" >> /etc/apk/repositories

# Atualiza e instala as dependências — build-base removido com sucesso
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

# Remove metadados e tabelas de símbolos do binário final
RUN strip -s -R .comment -R .gnu.version --strip-unneeded bwrap


# ==========================================
# ETAPA 2: Imagem Final Otimizada
# ==========================================
FROM alpine:edge

# Transfere apenas o binário executável estático e limpo
COPY --from=builder /bubblewrap/build/bwrap /usr/local/bin/bwrap

# Define o ponto de entrada do container
ENTRYPOINT ["/usr/local/bin/bwrap"]
# ==========================================
# ETAPA 1: Compilação (Ambiente de Build)
# ==========================================
FROM alpine:edge AS builder

# Configura os repositórios oficiais e garante a atualização dos índices em uma única camada limpa
RUN rm -f /etc/apk/repositories && \
    echo "https://alpinelinux.org" > /etc/apk/repositories && \
    echo "https://dl-cdn.alpinelinux.org/alpine/edge/community/" >> /etc/apk/repositories && \
    echo "http://alpinelinux.org" >> /etc/apk/repositories

# Atualiza os índices explicitamente antes de buscar as dependências (build-base REMOVIDO)
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

# Remove metadados do binário final (O comando strip necessita de utilitários do sistema já inclusos)
RUN strip -s -R .comment -R .gnu.version --strip-unneeded bwrap


# ==========================================
# ETAPA 2: Imagem Final Otimizada
# ==========================================
FROM alpine:edge

# Transfere apenas o binário executável estático e limpo
COPY --from=builder /bubblewrap/build/bwrap /usr/local/bin/bwrap

# Define o ponto de entrada do container
ENTRYPOINT ["/usr/local/bin/bwrap"]
