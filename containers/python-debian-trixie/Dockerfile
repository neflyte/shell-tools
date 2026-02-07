# Stage 1: The Builder
FROM debian:trixie-slim AS builder

# Set Python version
ARG PYTHON_VERSION=3.13.11

# Prevent interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Install build dependencies
RUN apt-get -qq update \
    && apt-get -qq upgrade -y \
    && apt-get install -y \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libncurses5-dev \
    libncursesw5-dev \
    libreadline-dev \
    libsqlite3-dev \
    libgdbm-dev \
    libdb-dev \
    libexpat1-dev \
    liblzma-dev \
    libffi-dev \
    libbz2-dev \
    uuid-dev \
    wget \
    curl \
    ca-certificates \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

# Download and extract source
WORKDIR /tmp/python_build
RUN wget -q https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tar.xz \
    && tar -xf Python-${PYTHON_VERSION}.tar.xz

# Configure, Build, and Install
# We use /opt/python3 as the prefix so it's self-contained
WORKDIR /tmp/python_build/Python-${PYTHON_VERSION}
RUN ./configure \
    --prefix=/opt/python3 \
    --enable-optimizations \
    --with-lto \
    --with-ensurepip=install \
    && make -j$(nproc) \
    && make install DESTDIR=/python_pkg

# Create the tarball of the resulting build
RUN tar -cf /python-trixie-build.tar.xz -C /python_pkg/opt/python3 .

# Stage 2: Export stage
FROM scratch AS exporter
COPY --from=builder /python-trixie-build.tar.xz /
