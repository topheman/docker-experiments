FROM nginx:alpine

COPY ./front/build /usr/share/nginx/html

COPY ./nginx/site.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

# CMD ["nginx"]