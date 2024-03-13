FROM alpine:latest

RUN apk add --no-cache bash

COPY install-packages.sh /tmp/
RUN chmod +x /tmp/install-packages.sh \
    && ./tmp/install-packages.sh \
    && rm -f /tmp/install-packages.sh

CMD ["/bin/bash"]