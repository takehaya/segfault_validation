
FROM alpine:3.8

RUN apk add --no-cache gcc libc-dev
ADD ./workspace /workspace
WORKDIR /workspace

RUN gcc main.c
