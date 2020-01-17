FROM node:11 AS node-builder
WORKDIR /src
COPY . .
RUN npm install -g @angular/cli
RUN npm install
RUN ng build --base-href=/um/ --prod --output-path dist/client/um

FROM nginx:1.15.2-alpine
COPY --from=node-builder /src/dist/client/um /usr/share/nginx/html/um
COPY nginx.site.template /etc/nginx/conf.d/
CMD envsubst '${BACKEND_URI}' < /etc/nginx/conf.d/nginx.site.template > /etc/nginx/conf.d/default.conf && exec nginx -g 'daemon off;'