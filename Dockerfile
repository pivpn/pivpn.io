FROM nginx

RUN apt update && apt upgrade -y
ADD assets /usr/share/nginx/html/assets
ADD images /usr/share/nginx/html/images
ADD index.html /usr/share/nginx/html
COPY nginx/pivpn.conf /etc/nginx/conf.d/pivpn.conf
RUN find /usr/share/nginx/html -type d -exec chmod 755 {} \;
RUN find /usr/share/nginx/html -type f -exec chmod 644 {} \;
