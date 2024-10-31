# Use an official Python runtime as a parent image
FROM python:3.11

ARG OPENAI_API_KEY
ARG CHROMA_API_KEY
ARG CHROMA_HOST
ARG CHROMA_PORT
ARG JWT_TOKEN_EXPIRE
ARG JWT_SECRET_KEY
ARG MYSQL_HOST
ARG MYSQL_PORT
ARG MYSQL_USERNAME
ARG MYSQL_PASSWORD
ARG MYSQL_DB

WORKDIR /app
ADD . /app
RUN pip install --no-cache-dir -r requirements.txt

ENV OPENAI_API_KEY=${OPENAI_API_KEY}
ENV CHROMA_API_KEY=${CHROMA_API_KEY}
ENV CHROMA_HOST=${CHROMA_HOST}
ENV CHROMA_PORT=${CHROMA_PORT}
ENV JWT_TOKEN_EXPIRE=${JWT_TOKEN_EXPIRE}
ENV JWT_SECRET_KEY=${JWT_SECRET_KEY}
ENV MYSQL_HOST=${MYSQL_HOST}
ENV MYSQL_PORT=${MYSQL_PORT}
ENV MYSQL_USERNAME=${MYSQL_USERNAME}
ENV MYSQL_PASSWORD=${MYSQL_PASSWORD}
ENV MYSQL_DB=${MYSQL_DB}

LABEL traefik.enable="true"
LABEL traefik.http.routers.api.entrypoints="web, websecure"
LABEL traefik.http.routers.api.rule="Host(`URI`)"
LABEL traefik.http.routers.api.tls="true"
LABEL traefik.http.routers.api.tls.certresolver="production"

EXPOSE 8080