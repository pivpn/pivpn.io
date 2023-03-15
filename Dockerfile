FROM nginx

COPY src /usr/share/nginx/html/
COPY nginx/pivpn.conf /etc/nginx/conf.d/pivpn.conf
RUN find /usr/share/nginx/html -type d -exec chmod 755 {} \;
RUN find /usr/share/nginx/html -type f -exec chmod 644 {} \;
