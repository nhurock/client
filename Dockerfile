FROM node:11 AS node-builder
WORKDIR /src
COPY . .
RUN npm install -g @angular/cli
RUN npm install
RUN npm run build -- --prod --output-path dist --base-href /um/

FROM nginxinc/nginx-unprivileged:1.15.5-alpine
# Use root user to copy dist folder and modify user access to specific folder

USER root
RUN apk add --no-cache  gettext
# Copy application and custom NGINX configuration
COPY --from=node-builder /src/dist /usr/share/nginx/html/um/
COPY /nginx-custom.conf /etc/nginx/conf.d/default.conf
# Setup unprivileged user 1001
RUN chown -R 1001 /usr/share/nginx/html/um/
# Use user 1001
USER 1001
# Expose a port that is higher than 1024 due to unprivileged access
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]

# FROM nginx:1.15.2-alpine
# COPY --from=node-builder /src/dist /usr/share/nginx/html/um
# COPY nginx.site.template /etc/nginx/conf.d/
# CMD envsubst '${BACKEND_URI}' < /etc/nginx/conf.d/nginx.site.template > /etc/nginx/conf.d/default.conf && exec nginx -g 'daemon off;'