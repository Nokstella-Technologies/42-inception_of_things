FROM nginx:alpine

# Copia o index.html com placeholder
COPY index.html /usr/share/nginx/html/index.html

# Adiciona um script de substituição
COPY entrySet.sh /entrySet.sh
RUN chmod +x /entrySet.sh

ARG APP_NAME
ARG NODE_NAME
ARG POD_NAME

ENTRYPOINT ["/entrySet.sh"]
CMD ["nginx", "-g", "daemon off;"]
