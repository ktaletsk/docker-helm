FROM alpine:3

ARG USER=helm

ARG TARGETOS=linux
ARG TARGETARCH=amd64
ARG KUBE_VERSION=1.28.4
ARG HELM_VERSION=3.13.2

ENV HOME /home/$USER
ENV PATH="$HOME/.local/bin:${PATH}"

RUN apk add --no-cache --update ca-certificates bash git openssh curl gettext jq bind-tools python3 py3-pip

RUN wget -q https://dl.k8s.io/release/v${KUBE_VERSION}/bin/{TARGETOS}/${TARGETARCH}/kubectl -O /usr/local/bin/kubectl \
    && wget -q https://get.helm.sh/helm-v${HELM_VERSION}-${TARGETOS}-${TARGETARCH}.tar.gz -O - | tar -xzO ${TARGETOS}-${TARGETARCH}/helm > /usr/local/bin/helm \
    && rm -rf /var/cache/api/* \
    && chmod +x /usr/local/bin/helm /usr/local/bin/kubectl \
    && adduser -D $USER -u 1001 -g 1001

USER $USER
WORKDIR $HOME

RUN pip3 install --upgrade pip \
    && pip3 install --no-cache-dir awscli \
    && mkdir .kube \
    && touch .kube/config \
    && chmod 777 .kube/config \
    && helm repo add "stable" "https://charts.helm.sh/stable" --force-update

CMD bash