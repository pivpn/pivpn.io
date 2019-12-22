FROM nginx

ADD assets /usr/share/nginx/html/assets
ADD images /usr/share/nginx/html/images
ADD index.html /usr/share/nginx/html
COPY nginx/pivpn.conf /etc/nginx/conf.d/pivpn.conf
