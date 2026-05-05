ARG UBUNTU_VERSION=24.04
FROM ubuntu:${UBUNTU_VERSION}

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y \
    python3 \
    python3-pip \
    python3-setuptools \
    python3-wheel \
    build-essential \
    debhelper \
    dh-python \
    fakeroot \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY . .

RUN python3 setup.py --command-packages=stdeb.command bdist_deb || true
