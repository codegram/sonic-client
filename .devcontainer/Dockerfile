FROM elixir:1.11.2-slim

ARG USERNAME=vscode

RUN apt-get update && \
    apt-get install -y inotify-tools && \
    apt-get install -y vim && \
    apt-get install -y git && \
    apt-get install -y curl && \
    apt-get install -y wget && \
    apt-get install -y gnupg2 && \
    apt-get install -y zsh && \
    apt-get install -y telnet


COPY setup.sh .
RUN bash ./setup.sh

ENV MIX_HOME=/home/root/.mix
ENV HEX_HOME=/home/root/.hex
