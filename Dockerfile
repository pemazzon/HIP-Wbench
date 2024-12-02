ARG CI_REGISTRY_IMAGE
ARG TAG
ARG DOCKERFS_TYPE
ARG DOCKERFS_VERSION
ARG JUPYTERLAB_DESKTOP_VERSION
FROM ${CI_REGISTRY_IMAGE}/${DOCKERFS_TYPE}:${DOCKERFS_VERSION}${TAG} AS base
LABEL maintainer="paoloemilio.mazzon@unipd.it"

ARG DEBIAN_FRONTEND=noninteractive
ARG CARD
ARG TAG
ARG CI_REGISTRY
ARG APP_NAME
ARG APP_VERSION

LABEL app_version=$APP_VERSION
LABEL app_tag=$TAG

WORKDIR /apps/${APP_NAME}
ENV PATH="/opt/${APP_NAME}/bin_linux64:$PATH"
ADD ./apps/${APP_NAME}/${APP_NAME}-linux64-v${APP_VERSION}.tgz /opt/
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    --mount=type=cache,target=/var/cache/curl,sharing=locked \
    apt-get update -qq \
    && apt-get install -y -q --no-install-recommends \
           libgomp1 \
           libxrender1 \
    && rm -rf /var/lib/apt/lists/*

ENV APP_CMD_PREFIX="export PATH=/opt/${APP_NAME}/bin_linux64:$PATH"
ENV APP_SPECIAL="terminal"
ENV APP_CMD=""
ENV PROCESS_NAME=""
ENV DATA_DIR_ARRAY=""

HEALTHCHECK --interval=10s --timeout=10s --retries=5 --start-period=30s \
  CMD sh -c "/apps/${APP_NAME}/scripts/process-healthcheck.sh \
  && /apps/${APP_NAME}/scripts/ls-healthcheck.sh /home/${HIP_USER}/nextcloud/"

COPY ./scripts/ scripts/

ENTRYPOINT ["./scripts/docker-entrypoint.sh"]
