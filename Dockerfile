FROM golang:1.16
LABEL maintainer "tomas@aparicio.me"

ARG LIBVIPS_VERSION=8.15.0
ARG GOLANGCILINT_VERSION=1.29.0

ENV GO111MODULE=off

# Installs libvips + required libraries
RUN DEBIAN_FRONTEND=noninteractive \
  apt-get update && \
  apt-get install --no-install-recommends -y \
  ca-certificates \
  meson build-essential cmake libgirepository1.0-dev libexpat1-dev libheif-dev curl \
  gobject-introspection gtk-doc-tools libglib2.0-dev libjpeg62-turbo-dev libpng-dev \
  libwebp-dev libtiff5-dev libgif-dev libexif-dev libxml2-dev libpoppler-glib-dev \
  swig libmagickwand-dev libpango1.0-dev libmatio-dev libopenslide-dev libcfitsio-dev \
  libgsf-1-dev fftw3-dev liborc-0.4-dev librsvg2-dev libimagequant-dev libaom-dev

RUN echo '/vips/lib' > /etc/ld.so.conf.d/vips.conf && \
  ldconfig -v && \
  export LD_LIBRARY_PATH="/vips/lib:$LD_LIBRARY_PATH" && \
  export PKG_CONFIG_PATH="/vips/lib/pkgconfig:$PKG_CONFIG_PATH" && \
  cd /tmp && \
  curl -fsSLO https://github.com/libvips/libvips/releases/download/v${LIBVIPS_VERSION}/vips-${LIBVIPS_VERSION}.tar.xz && \
  tar xvf vips-${LIBVIPS_VERSION}.tar.xz

RUN cd /tmp/vips-${LIBVIPS_VERSION} && \
  meson setup build --prefix /vips && \
  cd build && meson compile && meson test && \
  meson install && \
  ldconfig

ENV LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"

# Install runtime dependencies
# RUN DEBIAN_FRONTEND=noninteractive \
#   apt-get update && \
#   apt-get install --no-install-recommends -y \
#   libglib2.0-0 libjpeg62-turbo libpng16-16 libopenexr23 \
#   libwebp6 libwebpmux3 libwebpdemux2 libtiff5 libgif7 libexif12 libxml2 libpoppler-glib8 \
#   libmagickwand-6.q16-6 libpango1.0-0 libmatio4 libopenslide0 \
#   libgsf-1-114 fftw3 liborc-0.4-0 librsvg2-2 libcfitsio7 libimagequant0 libheif1 && \
#   apt-get autoremove -y && \
#   apt-get autoclean && \
#   apt-get clean && \
#   rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Go lint
RUN go get -u golang.org/x/lint/golint

ENV LD_LIBRARY_PATH="/vips/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH"
ENV PKG_CONFIG_PATH="/vips/lib/x86_64-linux-gnu/pkgconfig:/usr/local/lib/pkgconfig:/usr/lib/pkgconfig:/usr/X11/lib/pkgconfig"

WORKDIR ${GOPATH}/src/github.com/h2non/bimg
COPY . .

# RUN \
#   # Clean up
#   apt-get remove -y automake curl build-essential && \
#   apt-get autoremove -y && \
#   apt-get autoclean && \
#   apt-get clean && \
#   rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

CMD [ "/bin/bash" ]
