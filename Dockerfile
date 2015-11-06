FROM debian:jessie

# Download & install all required packages
RUN apt-get update; \
    apt-get install -y --no-install-recommends apache2 libapache2-mod-proxy-html transmission-daemon curl heirloom-mailx dnsutils cron minidlna; \
    rm -rf /var/lib/apt/lists/*

# Download apaxy
ENV APAXY_URL https://github.com/AdamWhitcroft/Apaxy/archive/master.tar.gz
RUN curl -kL "$APAXY_URL" | tar -C /tmp/ -zx && mv /tmp/Apaxy-master/apaxy/* /var/www/html/ && rm -rf /tmp/Apaxy-master

# Install forego
ENV FOREGO_URL https://github.com/viranch/forego/releases/download/0.16.2/forego
RUN curl -kL "$FOREGO_URL" -o /usr/local/bin/forego && chmod a+x /usr/local/bin/forego

# Setup apache
RUN for mod in proxy proxy_ajp proxy_balancer proxy_connect proxy_ftp proxy_html proxy_http proxy_scgi ssl xml2enc; do a2enmod $mod; done
ADD assets/config/apache2 /etc/apache2/conf-enabled/
ADD assets/dashboard/ /var/www/html/
RUN cd /var/www/html; \
    sed -i 's/{FOLDERNAME}\///g' htaccess.txt; \
    mv htaccess.txt .htaccess; \
    mv theme/htaccess.txt theme/.htaccess; \
    sed -i '/explore.*header\.html.*footer\.html/d' theme/footer.html; \
    sed -i 's/NameWidth=\*/NameWidth=40/g' .htaccess

# Setup transmission
ADD assets/config/transmission.json /opt/

# Setup minidlna
ADD assets/config/minidlna.conf /etc/minidlna.conf

# Add required scripts
ADD assets/scripts/ /opt/scripts/

# Setup forego, our process supervisor
ADD assets/config/forego/ /opt/forego/

# Finally declare public things
VOLUME /data
EXPOSE 80

# Define how to run the image
ENTRYPOINT ["/opt/scripts/start.sh"]
CMD ["forego", "start", "-f", "/opt/forego/Procfile", "-e", "/opt/forego/env", "-r"]
