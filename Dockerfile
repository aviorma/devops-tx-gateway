FROM nginx:1.29.3
LABEL maintainer="tx-gateway"
ENV NGINX_ENTRYPOINT_QUIET_LOGS=1

# Copy nginx configuration with health endpoint
COPY nginx-default.conf /etc/nginx/conf.d/default.conf
