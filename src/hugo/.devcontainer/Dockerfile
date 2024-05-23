FROM alpine:latest

RUN apk add --no-cache bash

RUN addgroup vscode && adduser -s /bin/bash --disabled-password --ingroup vscode vscode

COPY install-packages.sh /tmp/
RUN chmod +x /tmp/install-packages.sh \
  && ./tmp/install-packages.sh \
  && rm -f /tmp/install-packages.sh

# Persist Bash history for root
RUN SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
  && echo "$SNIPPET" >> "/root/.bashrc"

# Persist Bash history for non root user
RUN SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
    && mkdir /commandhistory \
    && touch /commandhistory/.bash_history \
    && chown -R vscode /commandhistory \
    && echo "$SNIPPET" >> "/home/vscode/.bashrc"