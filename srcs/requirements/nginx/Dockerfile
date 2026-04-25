FROM debian:12

RUN apt update -y && \
    apt install -y nginx \
    openssl

EXPOSE 443

COPY ./tools/generate_cert.sh /generate_cert.sh
RUN chmod 777 /generate_cert.sh && /bin/sh /generate_cert.sh

COPY ./conf/nginx.conf /etc/nginx/nginx.conf
CMD ["nginx", "-g", "daemon off;"]
