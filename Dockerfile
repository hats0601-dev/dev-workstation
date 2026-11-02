FROM nginx:stable-alpine

LABEL org.opencontainers.image.title="dev-workstation-web"
LABEL org.opencontainers.image.description="Development workstation mission web server"

COPY site/ /usr/share/nginx/html/

EXPOSE 80