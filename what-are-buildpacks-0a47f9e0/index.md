---
kind: tutorial

title: |-
  What are Buildpacks? Use cases, benefits, and a hands-on tutorial

description: |-
  This tutorial demonstrates the main capabilities of Cloud Native Buildpacks in a hands-on fashion. We learn how to build images, use them and publish them to a registry using CNB (Cloud Native Buildpacks).

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
  name: docker


# Uncomment to embed (one or more) challenges.
# challenges:
#   challenge_name_1: {}
#   challenge_name_2: {}

# Uncomment to add (one or more) background tasks.
tasks:
  setup_daemon:
    init: true
    machine: docker-01
    user: laborant
    run: |
      sudo curl -L https://github.com/jqlang/jq/releases/download/jq-1.8.2/jq-linux64 --output /usr/local/bin/jq

      sudo jq -n \
      'try input catch {} | .features["containerd-snapshotter"] = false' /etc/docker/daemon.json \
      | sudo tee /etc/docker/daemon.json > /dev/null

      sudo systemctl restart docker

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

  build_golang_image:
    machine: docker-01
    run: |
      pack build golang-hello --builder heroku/builder:26
  run_golang_image:
    machine: docker-01
    run: |
      docker run -p 8080:8080 golang-hello
  tag_golang_image:
    machine: docker-01
    run: |
      docker tag golang-hello registry.iximiuz.com/golang-hello:latest
  push_golang_image:
    machine: docker-01
    run: |
      docker push registry.iximiuz.com/golang-hello
---

## What is Buildpacks?

Buildpacks is a CNCF (Cloud Native Computing Foundation) project which enables building container images from your application source that can run on Docker, Kubernetes or any cloud-based container orchestration platform. It does so by automatically detecting things like which language your application was written in (i.e. by detecting files like `package.json`, `requirements.txt` or `go.mod`) and what dependencies your app uses (by reading the contents of those files) and automatically choosing a build-process that suits the detected information. It does not require a developer to provide a separate `Containerfile` that describes the process of building a container.

### Benefits of using Buildpacks

The main benefits of using Buildpacks are as follows

1. **No Containerfiles to manage** - You don't need to maintain a separate
  Containerfile anywhere which describes how your application should be built.
  Buildpacks read the context i.e. your source code and automatically pick
  up details of your application and create runtime image accordingly. That also means there is no Dockerfile to keep in sync, so source and image definition can't drift apart.

2. **Safer build process** - A build process that happens using buildpacks can
  generally be considered as a safer process than a typical docker build, because it does not involve choosing a base image and doing any operations on that base image to create layers. A buildpack build-process generally just involves downloading dependencies needed for the application + compiling and creating a binary of your application if it is a compiled language source code and then attaching the final result to a runtime image, which the builder already has configured. The build process does not require root at any level.

3. **Flexibility of changing base layers of runtime image** - Because of the build process defined in the previous point,
  you get the flexibility to use the `rebase` feature. It allows on-demand swapping of the base layer of any runtime container image built with buildpacks, without running the entire build pipeline. This lets you quickly swap the base OS of an existing image, for reasons such as:

    * Updating to a newer OS version if one is available.
    * Patching images that have critical vulnerabilities.

### What is it not?

* It is not a replacement for standard ways to build a container.
* It does not always produce the most optimized container image.
* It will not always work out of the box for your custom source code structure. (It can work, but you will need to create your own buildpacks for it 😉)

Buildpacks actually predates Docker and Kubernetes. It was developed by [Heroku (now part of Salesforce)](https://heroku.com) to support deployments on its Cloud Platform. It allowed deployment of applications directly on servers without a developer needing to know the process with which it happens. Buildpacks was a way for them to take the source code, package it into something deployable and then run it on their dynos (isolated containers). It was one of the first PaaS (Platform as a Service) offerings. Here's a [link](https://www.heroku.com/blog/buildpacks/) to the blog post that announced Buildpacks.

::details-box
---
:summary: (optional and unrelated) - My first API implementation that I deployed on a Cloud Platform.
---
It was deployed on Heroku

Here's the link - https://github.com/gat786/quiz_api
::

## Hands on demo time

### Building applications

Click on the `START TUTORIAL` button and we can get going.

You will see that the `pack` CLI is installed and available for you in the environment. It is the tool used to build images with buildpacks.

Let's invoke the first `pack` command.

```sh
pack
```

Let's see what version of the `pack` CLI is available -
(if it is a very old one, someone will need to upgrade it.)

```sh
pack --version
```

You will also see that there is an `examples` directory. It contains the `golang-hello`, `python-hello` and `nodejs-hello` sample apps.

We will try to build container images for these fairly simple applications using pack.

Go to the `examples/golang-hello` directory and then run the following command

```
pack build golang-hello --builder heroku/builder:26
```

::simple-task
---
:tasks: tasks
:name: build_golang_image
---
#active
please build golang-hello docker image using pack.

#completed
golang-hello docker image was built.
::

In the above command - `golang-hello` is the docker image name that pack would create. The `--builder` flag specifies which builder pack uses in order to complete the build process. We are using the builder provided by Heroku. (Ref - https://github.com/heroku/cnb-builder-images). A typical pack command only requires you to specify a builder and an image name. The directory in which you run the command is automatically used as the build context.

Once the build process completes, we can then run the image using

```
docker run -p 8080:8080 golang-hello
```

::simple-task
---
:tasks: tasks
:name: run_golang_image
---
#active
please run the golang-hello docker image using Docker CLI.

#completed
golang-hello docker image was successfully run using Docker CLI.
::

Test the built API endpoint by opening another terminal and running

```sh
curl localhost:8080
```

Since this is a standard Docker image, it can be tagged and pushed to any registry. Let's do that.

```sh
docker tag golang-hello registry.iximiuz.com/golang-hello:latest
```

::simple-task
---
:tasks: tasks
:name: tag_golang_image
---
#active
please tag the golang-hello docker image using Docker CLI so that it can be pushed.

#completed
golang-hello docker image was successfully tagged
::

```sh
docker push registry.iximiuz.com/golang-hello:latest
```

::simple-task
---
:tasks: tasks
:name: push_golang_image
---
#active
please push the golang-hello docker image using Docker CLI.

#completed
golang-hello docker image was successfully pushed to a registry.
::

Similarly, you can build images for the `python-hello` and `nodejs-hello` directories.

### Investigating the build process

If you look closely at the build logs, you will see (this is for the golang-hello build process, but other languages will have similar outputs).

* It downloads the builder first, i.e. `heroku/builder:26`. The entire process
  afterwards runs inside this container image, with the context directory mounted in.
* It runs lifecycle steps
  i.e. the lines that begin with `===>` and have titles like `Detecting`, `Analyzing`, `Restoring`, `Building` and `Exporting`. These are building blocks that are present within the builder image.
* The `Detecting` and `Building` phases are the most important among the
  ones listed above, because this is where the builder actually detects what needs to be done and then executes the `Building` steps depending on that.
* You will see that during the `Building` phase, two buildpacks took part.
  First one is the official language buildpack, in this case `Heroku Go Buildpack` and `Procfile` buildpack. `Procfile` is a simple text file present in the application directory which contains text `web: golang-hello`. i.e. the runtime application is a webservice and it runs by executing the binary named `golang-hello`. You can read more about it [here](https://devcenter.heroku.com/articles/procfile).
