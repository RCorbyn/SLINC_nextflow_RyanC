FROM rocker/r2u:22.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    cmake \
    && apt-get install -y --install-recommends \
    openslide-tools \
    python3-openslide \
    python3-pil \
    git \
    tesseract-ocr \ 
    libtesseract-dev \
    python3-opencv \
    # Building ImageMagick
    && git clone https://github.com/ImageMagick/ImageMagick.git && \
    cd ImageMagick && \
    ./configure --without-magick-plus-plus --disable-docs --disable-static --with-tiff --with-jxl --with-tcmalloc && \
    make && make install && \
    ldconfig /usr/local/lib && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /ImageMagick 

# run with docker build --platform="linux/amd64" -t nextflow_mhp_docker .