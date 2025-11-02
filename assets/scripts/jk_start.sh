#!/bin/bash

if [[ -z "$JACKETT_API_KEY" ]]; then
    jk_conf="/jackett/Jackett/ServerConfig.json"
    test -f $jk_conf && export JACKETT_API_KEY=`jq -r .APIKey < $jk_conf`
fi

if [[ -n "JACKETT_API_KEY" ]]; then
    sed -i 's/jk_api = ".*"/jk_api = "'$JACKETT_API_KEY'"/g' /var/www/html/scripts/stuff.js
fi

exec "$@"
