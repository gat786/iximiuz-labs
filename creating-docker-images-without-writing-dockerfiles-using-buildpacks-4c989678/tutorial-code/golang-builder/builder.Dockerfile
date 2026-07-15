# Define the base image
FROM ubuntu:resolute

# Install packages that we want to make available at build time
RUN apt-get update && \
  apt-get install -y xz-utils ca-certificates wget && \
  rm -rf /var/lib/apt/lists/*

# Set required CNB user information
ARG cnb_uid=2000
ARG cnb_gid=2000
ENV CNB_USER_ID=${cnb_uid}
ENV CNB_GROUP_ID=${cnb_gid}

# Create user and group
RUN groupadd cnb --gid ${CNB_GROUP_ID} && \
  useradd --uid ${CNB_USER_ID} --gid ${CNB_GROUP_ID} -m -s /bin/bash cnb

ADD --chown=${CNB_USER_ID}:${CNB_GROUP_ID} --chmod=755 https://github.com/sclevine/yj/releases/download/v5.1.0/yj-linux-amd64 /usr/local/bin/yj
ADD --chown=${CNB_USER_ID}:${CNB_GROUP_ID} --chmod=755 https://github.com/jqlang/jq/releases/download/jq-1.8.2/jq-linux-amd64 /usr/local/bin/jq

# Set user and group
USER ${CNB_USER_ID}:${CNB_GROUP_ID}

# Set required CNB target information
LABEL io.buildpacks.base.distro.name="ubuntu"
LABEL io.buildpacks.base.distro.version="26.04"

