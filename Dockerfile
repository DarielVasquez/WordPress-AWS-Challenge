FROM ubuntu:22.04

ARG SERVER_NAME
ENV SERVER_NAME=${SERVER_NAME}
ENV MYSQL_DATABASE="wordpress_db"
ENV MYSQL_USER="wordpress_user"
ENV MYSQL_PASSWORD="password"
ENV DB_HOST="localhost"

COPY scripts/docker_config.sh /usr/local/bin/docker_config.sh
COPY scripts/start_services.sh /usr/local/bin/start_services.sh

RUN chmod +x /usr/local/bin/docker_config.sh && \
    /usr/local/bin/docker_config.sh && \
    chmod +x /usr/local/bin/start_services.sh

EXPOSE 80

CMD ["/usr/local/bin/start_services.sh"]