# The official image already starts Nginx in the foreground.
FROM nginx:stable-alpine
COPY --chmod=644 index.html /usr/share/nginx/html/index.html
EXPOSE 80
