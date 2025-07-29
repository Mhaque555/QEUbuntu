FROM debian:12-slim

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
      qemu-system-x86 qemu-utils cloud-guest-utils \
      curl ca-certificates genisoimage openssh-client \
      git python3 websockify && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /vm
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
