---
kind: tutorial

title: |-
  What are buildpacks, understanding the usecases, benefits and capabilities

description: |-
  This is a sample tutorial that demonstrates main capabilities of Cloud Native Buildpacks

categories:
- linux
- containers

tagz:
- docker
- container-image
- dockerfile

createdAt: 2026-08-02
updatedAt: 2026-08-02

cover: __static__/cover.png

playground:
  name: podman


# Uncomment to embed (one or more) challenges.
# challenges:
#   challenge_name_1: {}
#   challenge_name_2: {}

# Uncomment to add (one or more) background tasks.
tasks:
  init_task_1:
    init: true
    run: ...
  regular_task_1:
    run: ...
tasks:
  clone_samples:
    init: true
    machine: docker-01
    user: laborant
    run: |
      trap 'rm -rf ./*.zip' EXIT;

      wget https://github.com/gat786/iximiuz-labs/releases/download/release-20/examples.zip
      unzip examples.zip

  install_pack_cli:
    init: true
    machine: docker-01
    user: laborant
    run: |
      ORG=buildpacks
      REPO=pack
      OS=linux

      VERSION=v0.40.7
      echo "Version: $VERSION"

      TEMP_DIR=$(mktemp -d)

      FILE_NAME="$REPO-$VERSION-$OS.tgz"
      URL="https://github.com/$ORG/$REPO/releases/download/$VERSION/$FILE_NAME"

      echo "Downloading from $URL";
      curl -o $TEMP_DIR/$FILE_NAME -SL "$URL"
      sudo tar -C /usr/local/bin/ --no-same-owner -xvf "$TEMP_DIR/$FILE_NAME"

      echo "Installed: $("$REPO" --version)"
---

## What is Buildpacks?

Buildpacks is a CNCF (Cloud Native Computing Foundation) project which enables building container images from your application source that can run on any cloud. It does so by automatically detecting things like which language your application was written in (i.e. by detecting files like `package.json` or `requirements.txt`) and what dependencies does your app use etc. without them needing to specified in a separate `Containerfile` and uses them to prepare a container image.

### Benefits of using Buildpacks

The main benefits of using Buildpacks are as follows

1. **No Containerfiles to manage** - You don't need to maintain a separate
  Containerfile anywhere which describes how your application should be build.
  Buildpacks read the context i.e. your source code and automatically pick
  up finer details of your application and create run time image accordingly.

2. **Flexibility of changing base layers of runtime image** You get
  flexibility of using `rebase` feature. It is a feature that allows on demand
  of swapping base layer of any pre-built runtime container image without running
  the entire build pipeline. This feature allows you rebuilt images quickly for

    * Patching images that have critical vulnerabilities in them.
    * Updating base layer of runtime image with newer software when available
    even for software that was built a long time ago, this allows fixing of runtime
    container images created by buildpacks with matching base layer images.

## Hands on demo time

### What is it not?

* It is not a replacement for standard ways to build a container.
* It does not always produce the most optimised container image.
* It will not always work out of the box for your custom source code structure.


### A little of history...

The concept of buildpacks is not new, its actually older then docker itself. It was built by [heroku](https://heroku.com) which used to be the OG PaaS Cloud Platforn when I was still in college, some 6-7 years ago. I remember using heroku to deploy my backend code of my college project. Heroku has recently announced that it will no longer be accepting any new enterprise customers. It means that the Cloud Platform scenario has changed a lot from that point wards and that they are probably trying to upgrade themselves as well.
