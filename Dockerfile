FROM ubuntu:24.10@sha256:707879280c0bbfe6cbeb3ae1a85b564ea2356b5310a122c225b92cb3d1ed131b
ENV ANSIBLE_VERSION 2.16.14
RUN apt-get update; \
    apt-get install -y gcc python3; \
    apt-get install -y python3-pip; \
    apt-get clean all
RUN pip3 install --upgrade pip; \
    pip3 install "ansible==${ANSIBLE_VERSION}"; \
    pip3 install ansible
