FROM mysql:latest

ENV MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}
ENV MYSQL_DATABASE=Projects

COPY ./init.sql /docker-entrypoint-initdb.d/

EXPOSE 3306