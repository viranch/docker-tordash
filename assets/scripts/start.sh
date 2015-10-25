#!/bin/bash

if [[ -n "$AUTH_USER" ]]; then
    echo $AUTH_PASS | htpasswd -ic /etc/apache2/htpasswd $AUTH_USER
    cat << EOF > /etc/apache2/conf-enabled/auth.conf
<Location />
    AuthType Basic
    AuthName "By Invitation Only"
    AuthUserFile /etc/apache2/htpasswd
    Require valid-user
</Location>
EOF
fi

mkdir -p /data/{transmission,watch,downloads}
test ! -f /data/transmission/settings.json && cp /opt/transmission.json /data/transmission/settings.json
test ! -L /var/www/html/downloads && ln -s /{data,var/www/html}/downloads

mkdir -p /run/minidlna

list() { l=`echo $@ | sed 's/,/" "/g'`; echo "(\"$l\")"; }
eval FEEDS=`list $RSS_FEED`
eval OPTS=`list $TV_OPTS`

rm -f /opt/tv.cron
for i in "${!FEEDS[@]}"; do
    feed="${FEEDS[$i]}"
    opts="${OPTS[$i]}"
    test -n "$feed" && echo "30 4 * * * /opt/scripts/tv.sh -l $feed -o /data/watch $opts" >> /opt/tv.cron
done
test -f /opt/tv.cron && crontab /opt/tv.cron

exec "$@"
