#!/bin/sh

PUBLIC_URL=""
if [ -n "${OSC_HOSTNAME}" ]; then
  PUBLIC_URL="https://${OSC_HOSTNAME}"
fi

cat << EOF > config.json
{
  "wwwAddress": "0.0.0.0",
  "wwwPort": 3000,
  "wwwPublicURL": "${PUBLIC_URL}",
  "serviceAddress": "0.0.0.0",
  "servicePort": 8085,
  "servicePublicURL": "${PUBLIC_URL}",
  "smtpAddress": "0.0.0.0",
  "smtpPort": 2500,
  "dbEngine": "SQLite",
  "dbHost": "",
  "dbPort": 0,
  "dbDatabase": "./mailslurper.db",
  "dbUserName": "",
  "dbPassword": "",
  "maxWorkers": 1000,
  "autoStartBrowser": false,
  "keyFile": "",
  "certFile": "",
  "adminKeyFile": "",
  "adminCertFile": ""
}
EOF

./mailslurper &

exec "$@"