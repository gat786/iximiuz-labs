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

Buildpacks is a CNCF (Cloud Native Computing Foundation) project which enables building container images from your application source that can run on Docker, Kubernetes or any cloud based container orchestration platform for that matter. It does so by automatically detecting things like which language your application was written in (i.e. by detecting files like `package.json`, `requirements.txt` or `go.mod`) and what dependencies does your app uses (by reading the content of those file) and automatically choosing a build-process that suits the detected workload information. It does not require a developer to provide a separate `Containerfile` that describes process of building a container.

### Benefits of using Buildpacks

The main benefits of using Buildpacks are as follows

1. **No Containerfiles to manage** - You don't need to maintain a separate
  Containerfile anywhere which describes how your application should be build.
  Buildpacks read the context i.e. your source code and automatically pick
  up finer details of your application and create run time image accordingly. That also means that there is no need to maintain a common ground between application source code and dockerfiles since they can drift apart during development phases. Buildpacks automatically picks up the finer details by reading the context.

2. **Safer build process** - A build process that happens using buildpacks can
  generally be considered as a safer process than typically docker build, because it does not involve choosing a base image and doing any operations on that base image to create layers. A buildpack build-process generally just involves downloading dependencies needed for application + compiling and creating a binary of your application if it is a compiled language source code and then attaching the final result to a run-time image, which the buildpack already has configured. The build process does not require root at any level.

3. **Flexibility of changing base layers of runtime image** - Because of the
  build process defined in the previous point.  You get flexibility of using `rebase` feature. It is a feature that allows on demand of swapping base layer of any pre-built runtime container image without running the entire build pipeline. This feature allows you to replace runtime container image's base operating system quickly for any reason which may be -

    * Patching images that have critical vulnerabilities in them.
    * Updating with newer version of OS software when available if the OS layer is compatible enough.

### What is it not?

* It is not a replacement for standard ways to build a container.
* It does not always produce the most optimised container image.
* It will not always work out of the box for your custom source code structure. (it can work but you will need to create your own buildpacks for them 😉)

Buildpacks actually pre-dates docker and kubernetes as a whole. It was developed by [Heroku (Now part of Salesforce)](https://heroku.com) to support deployments on their Cloud Platform. They allowed deployment of applications directly on servers without a developer needing to know the process with which it happens. Buildpacks was a way for them to take a source code, package it into something deployable and then run it on their dynos (virtual machines). It was the original PAAS (Platform As A Service offering) if I may say so. Here's a [link](https://www.heroku.com/blog/buildpacks/) to the blog post that announces Buildpacks.

::details-box
---
:summary: (optional and unrelated) - My first api implementation that I deployed on a Cloud Platform.
---
It was deployed on Heroky (FYI)

Here's the link - https://github.com/gat786/quiz_api
::

## Hands on demo time

### Building applications

Click on `START TUTORIAL` button and we can get going.

You will see that `pack` CLI is installed and available for you on the environment. It is the tool that is used to build containers using buildpacks.

Let's invoke the first `pack` command.

```
pack
```

Let's see the version of pack CLI that we have available -
(if it is a very old one at some point, some one would need to upgrade it.)

```
pack --version
```

You will also see that there is an `examples` directory. This directory then further contains `golang-hello`, `python-hello` and `nodejs-hello` application source codes in them.

We will try to build container images for these fairly simple applications using Pack.

Go in the `examples/golang-hello` directory and then run the following command

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
golang-hello docker image was build.
::

In the above command - `golang-hello` is the docker image name that pack would create. The `--builder` flag specifies which builder does pack uses inorder to complete the build process. We are in our example using the default ones provided by heroku. (Ref - https://github.com/heroku/cnb-builder-images). A typical pack command only involves you specify a builder and a image name. The directory in which you run the command is automatically considered as the context and considered for building the image.

Once the build process completes we can then run the image using

```
docker run -p 8080:8080 golang-hello
```

::simple-task
---
:tasks: tasks
:name: run_golang_image
---
#active
please run golang-hello docker image using docker cli.

#completed
golang-hello docker image was successfully ran using docker cli.
::

Test the built api endpoint by opening another terminal and running

```
curl localhost:8080
```

::simple-task
---
:tasks: tasks
:name: tag_golang_image
---
#active
please tag golang-hello docker image using docker cli so that it can be pushed.

#completed
golang-hello docker image was successfully tagged
::

::simple-task
---
:tasks: tasks
:name: push_golang_image
---
#active
please push the golang-hello docker image using docker cli.

#completed
golang-hello docker image was successfully pushed to a registry.
::

Similarly, you can create containers for the `python-hello` and `nodejs-hello` directories as well.

### Investigating the build process

If you look at the build process logs clearly you will see (this is for the golang-hello build process, but other languages will have similar outputs)

* It downloads the builder first, i.e. `heroku/builder:26`. The entire process
  afterwards runs within the confinements of this container along with the context directory.
* It runs lifecycle steps
  i.e. the lines that begin with `===>` and have titles like `Analyzing`, `Detecting`, `Restoring`, `Building` and `Exporting`. These are building blocks that are present within the builder image.
* `Detecting` and `Building` phase are the most important phases amongst the
  above listed. Because this is where builder actually detects what needs to be done and then executes the `Building` steps depending on that.
* You will see that during the `Building` phase, two buildpacks took part.
  First one is the official language buildpack, in this case `Heroku Go Buildpack` and `Procfile` buildpack. `Procfile` is a simple text file present in the application directory which contains text `web: golang-hello`. i.e. the runtime application is a webservice and it runs by executing the binary named `golang-hello`. You can read more about it [here](https://devcenter.heroku.com/articles/procfile).
