FROM node:10 AS node-builder
WORKDIR /
COPY . .
RUN npm install -g @angular/cli
RUN npm install
RUN ng build --prod

FROM nginx:1.15.2-alpine
COPY --from=node-builder /dist /usr/share/nginx/html
COPY nginx.site.template /etc/nginx/conf.d/
CMD envsubst '${BACKEND_URI}' < /etc/nginx/conf.d/nginx.site.template > /etc/nginx/conf.d/default.conf && exec nginx -g 'daemon off;'