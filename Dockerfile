FROM ghcr.io/viranch/dropbox

# install runtime dependencies of this docker image
RUN apt-get update && \
    apt-get install -y --no-install-recommends libxml2-utils jq && \
    rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*

# Setup apache
RUN for mod in headers proxy proxy_ajp proxy_balancer proxy_connect proxy_ftp proxy_html proxy_http proxy_scgi ssl xml2enc; do a2enmod $mod; done
COPY assets/config/apache2 /etc/apache2/conf-enabled/

# Add our dashboard and the apaxy file browser
COPY assets/dashboard/ /var/www/html/

# Add required scripts
COPY assets/scripts/ /opt/scripts/

# Finally declare public things
VOLUME /downloads
EXPOSE 80

# Define how to run the image
ENV DATA_DIR_NAME=downloads
ENTRYPOINT ["/opt/scripts/start.sh"]
CMD ["/opt/scripts/jk_start.sh"]
