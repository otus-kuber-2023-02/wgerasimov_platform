ARG IMAGE=openresty/openresty:centos-rpm

FROM $IMAGE

WORKDIR /app
RUN sed -ir 's/\/usr\/local\/openresty\/nginx\/html/\/app/g' /etc/nginx/conf.d/default.conf
RUN sed -ir 's/listen       80;/listen       8000;/g' /etc/nginx/conf.d/default.conf
RUN chown 1001:1001 -RH /usr/local/openresty && chown 1001:1001 -RH /var/run/openresty
EXPOSE 8000
USER 1001
