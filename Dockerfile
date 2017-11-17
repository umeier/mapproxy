FROM ubuntu:zesty
MAINTAINER Ulrich Meier <ulrich.meier@ldbv.bayern.de>
ENV DEBIAN_FRONTEND noninteractive
ENV http_proxy http://www-proxy.bybn.de:80/
ENV https_proxy http://www-proxy.bybn.de:80/
ENV no_proxy localhost,127.0.0.1,.va-lvg.bayern.de,.bvv.bayern.de,.lvg.bayern.de,.bybn.de,.int-dmz.bayern.de,.rz-nord.bayern.de

RUN mkdir /app
RUN mkdir /target
RUN mkdir /conf

WORKDIR /app

#
# Install packages
#
RUN         set -x \
            &&  apt-get -q update \
            &&  apt-get -yq --no-install-recommends install \
                    locales \
                    netbase \
                    ca-certificates \
                    curl \
                    build-essential \
                    gcc \
                    imagemagick \
                    libmapnik3.0 \
                    mapnik-utils \
                    \
                    python3 \
                    cython3 \
                    python3-pip \
                    python3-wheel \
                    python3-setuptools \
                    python3-dev \
                    python3-pil \
                    python3-numpy \
                    python3-scipy \
                    python3-pylibmc \
                    python3-skimage \
                    python3-gdal \
                    python3-mapnik \
		            python3-shapely \
		            python3-pyproj \
		            python3-pip \
		            python3-lxml

# COPY requirements-tests.txt /app/requirements.txt
# RUN pip3 install -r requirements.txt

ADD . /app/src
RUN pip3 install ./src
RUN pip3 install PyYAML
RUN pip3 install eventlet
RUN pip3 install gunicorn


COPY files/BETA2007.gsb /usr/share/proj/
COPY files/epsg /usr/share/proj/

RUN cp /app/src/mapproxy/config_template/base_config/mapproxy.yaml /conf
COPY config.py /app

CMD gunicorn -w 12 -t 300 -b :8080 config:application
