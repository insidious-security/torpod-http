FROM alpine:latest
RUN apk add --no-cache tor nginx
RUN adduser -S -G nginx -s /bin/sh torrin


ENV TOR_USER=torrin
ENV TOR_GROUP=nginx
RUN tor --verify-config && tor --hash-password "GENERATED_KEY_HERE" > /etc/tor/tor_password
RUN mkdir -p /var/lib/tor/hidden_service \
    && chown -R ${TOR_USER}:${TOR_GROUP} /var/lib/tor/hidden_service \
    && chmod -R 0700 /var/lib/tor/hidden_service
RUN echo "HiddenServiceDir /var/lib/tor/hidden_service" >> /etc/tor/torrc \
    && echo "HiddenServicePort 80 127.0.0.1:80" >> /etc/tor/torrc
EXPOSE 80 9050


ENV NGINX_USER=torrin
ENV NGINX_GROUP=nginx
RUN mkdir -p /var/www/html && chown -R ${NGINX_USER}:${NGINX_GROUP} /var/www/html
COPY nginx.conf /etc/nginx/nginx.conf
RUN nginx -t
RUN mkdir -p /var/log/nginx \
    && chown -R ${NGINX_USER}:${NGINX_GROUP} /var/log/nginx \
    && chmod -R 750 /var/log/nginx
RUN mkdir -p /var/lib/nginx/tmp/client_body \
    && chown -R ${NGINX_USER}:${NGINX_GROUP} /var/lib/nginx/tmp \
    && chmod -R 750 /var/lib/nginx/tmp
RUN mkdir -p /run/nginx \
    && chown -R ${NGINX_USER}:${NGINX_GROUP} /run/nginx \
    && chmod -R 750 /run/nginx


WORKDIR /var/www/html
COPY . /var/www/html/
RUN chown -R ${NGINX_USER}:${NGINX_GROUP} /var/www/html
USER torrin
CMD tor & nginx -g 'daemon off;'
