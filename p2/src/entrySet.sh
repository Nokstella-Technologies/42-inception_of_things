#!/bin/sh
# Cria env.js baseado nas variáveis do container
cat <<EOF >/usr/share/nginx/html/env.js
window.APP_NAME = "${APP_NAME}";
window.POD_NAME = "${POD_NAME}";
window.NODE_NAME = "${NODE_NAME}";
EOF

exec "$@"
