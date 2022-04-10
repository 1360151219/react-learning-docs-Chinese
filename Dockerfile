FROM node:14.15.0 as builder
COPY . .

FROM nginx:alpine as server

COPY --from=builder nginx.conf /etc/nginx/nginx.conf
COPY --from=builder build /var/www/react/
WORKDIR /var/www/react/ 
# FROM nginx:latest
# COPY nginx.conf /etc/nginx/nginx.conf
# COPY public /var/www/blog/
