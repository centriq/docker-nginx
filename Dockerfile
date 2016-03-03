FROM debian:jessie

MAINTAINER Nate Riffe <nate@centriqhome.com>

ENV NGINX_VERSION=1.9.11
ENV NGINX_STICKY_VERSION 1.2.6
ENV NGINX_STICKY_HASH c78b7dd79d0d

COPY nginx.list /etc/apt/sources.list.d/nginx.list
COPY nginx-sticky-module.patch /opt/nginx-sticky-module.patch

RUN (cd /opt; \
    DEBIAN_FRONTEND=noninteractive \
    apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62 && \
    apt-get update && \
    apt-get install -y ca-certificates wget && \
    apt-get build-dep -y nginx=$NGINX_VERSION && \
    apt-get source nginx=$NGINX_VERSION && \
    patch -p0 < nginx-sticky-module.patch && \
    wget -c https://bitbucket.org/nginx-goodies/nginx-sticky-module-ng/get/$NGINX_STICKY_VERSION.tar.gz --output-document=nginx-sticky-module-ng.tar.gz && \
    tar xvf nginx-sticky-module-ng.tar.gz && \
    mv nginx-goodies-nginx-sticky-module-ng-$NGINX_STICKY_HASH nginx-sticky-module-ng && \
    (cd nginx-1.9.11; \
      debian/rules clean && \
      debian/rules build && \
      debian/rules binary \
    ) && \
    dpkg -i nginx_1.9.11-1~jessie_amd64.deb && \
    apt-get purge --auto-remove -y debhelper build-essential && \
    rm -Rf /opt/* && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    ln -sf /dev/stdout /var/log/nginx/access.log && ln -sf /dev/stderr /var/log/nginx/error.log \
  )

EXPOSE 80 443
CMD [ "nginx", "-g", "daemon off;" ]
