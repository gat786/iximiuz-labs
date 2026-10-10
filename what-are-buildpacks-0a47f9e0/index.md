---
kind: tutorial

title: |-
  What are Buildpacks? Use Cases, Benefits, Hands-On experience with Guide to going through production.

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

cover: __static__/cover-buildpacks-v1.png

playground:
  name: docker


# Uncomment to embed (one or more) challenges.
# challenges:
#   challenge_name_1: {}
#   challenge_name_2: {}

# Uncomment to add (one or more) background tasks.
tasks:
  setup_trivy:
    init: true
    machine: docker-01
    user: laborant
    run: |
      ark get trivy
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
    needs:
      - setup_daemon
      - clone_samples
      - install_pack_cli
    run: |
      if ! docker images --format '{{.Repository}}' | grep -q '^golang-hello$'; then
          return 1;
      fi

  run_golang_image:
    machine: docker-01
    needs:
      - setup_daemon
      - clone_samples
      - install_pack_cli
      - build_golang_image
    run: |
      if docker ps --filter "ancestor=golang-hello" | grep -q golang-hello; then
          echo "A container from the golang-hello image is currently running."
          exit 0;
      fi

      exit 1;

  tag_golang_image:
    machine: docker-01
    needs:
      - setup_daemon
      - clone_samples
      - install_pack_cli
      - build_golang_image
      - run_golang_image
    run: |
      if ! docker image inspect registry.iximiuz.com/golang-hello:latest > /dev/null 2>&1; then
          exit 1
      fi

  push_golang_image:
    machine: docker-01
    needs:
      - setup_daemon
      - clone_samples
      - install_pack_cli
      - build_golang_image
      - tag_golang_image
    run: |
      if ! docker manifest inspect registry.iximiuz.com/golang-hello:latest > /dev/null 2>&1; then
          exit 1
      fi

  build_wolfi_run_image:
    machine: docker-01
    needs:
      - build_golang_image
    run: |
      if ! docker image inspect golang-hello-run:wolfi > /dev/null 2>&1; then
          exit 1
      fi

  rebase_golang_image:
    machine: docker-01
    needs:
      - build_wolfi_run_image
    run: |
      if ! docker run --rm --entrypoint cat golang-hello /etc/os-release 2>/dev/null | grep -q '^ID=wolfi'; then
          exit 1
      fi
---

## What is Buildpacks?

::image-box
---
:src: __static__/cover-buildpacks-v1.png
:alt: 'A brief about how buildpacks function and what it does'
---
::

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

```sh
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

```sh
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
  First one is the official language buildpack, in this case `Heroku Go Buildpack` and `Procfile` buildpack. `Procfile` is a simple text file present in the application directory which contains text `web: golang-hello`. i.e. the runtime application is a webservice and it runs by executing the binary named `golang-hello`. You can read more about it [here](https://devcenter.heroku.com/articles/procfile). The Procfile buildpack is used to configure an `ENTRYPOINT` for your docker container. It can be used to specify a specific command that you want to be the entrypoint for your application.

## Poking around in the build artifacts

While Buildpacks do end up creating a Docker Image, its not the same thing as using a Dockerfile and building one. Buildpacks use builders (we provided one using the `--builder` flag in our small tutorial) to automate build process and these builders contain Buildpack definitions which are nothing but scripts that execute a certain part of build lifecycle. So a container image is created by running scripts i.e. `DETECTION`, `BUILD` etc which in turn create docker image layers which are then bolted on top of a default run-image that a builder is already configured with.

We can see that by investigating the image that we just generated, lets do that.

```sh
docker inspect registry.iximiuz.com/golang-hello:latest | grep "io.buildpacks.base.distro.name" -A 2
```

You will see that the base image is a standard Ubuntu LTS release versioned 26.04. It is by default the base runner image for `heroku/builder:26` that we chose. It is a good base image choice when you consider that the same builder can build images for `7` [different languages](https://github.com/heroku/buildpacks#heroku-cloud-native-buildpacks) and a run-image specified on the builder should support all the different artifacts the build process creates. But it also comes with its costs. Lets put the image under scanner by putting it through [Trivy](https://trivy.dev).


::remark-box
---
kind: info
---

Trivy is a security tool that can scan container image artifacts and report the number of vulnerabilities that it sees within the image.
::


```sh
trivy image --table-mode summary \
  registry.iximiuz.com/golang-hello:latest
```

You will see a report which says that we currently have `> 350` vulnerabilities found. More than 90% of which are from the base image that we don't actually need.

It is definitely not a safe choice for when you are going to production and want to keep vulnerabilities to a minimum. It unnecessarily adds vulnerable elements from the entire ubuntu-stack to an artifact that only needs to execute a single golang binary. Security teams have a field day when something like this shows up. The `pack` CLI and thereby `CNB` have a feature known as `rebase`. It allows a user to swap the base run image of any container created using `CNB` to a compatible prebuilt or custom-built image.

### Rebasing onto a lean Wolfi run image

Our image is really two things stacked together: the **run image** layers (Ubuntu, provided by the builder) and the **app layers** (our compiled Go binary plus some launch metadata). `pack rebase` swaps the first part and leaves the second part untouched. No rebuild, no recompilation.

We'll swap Ubuntu for [Wolfi](https://github.com/wolfi-dev), a minimal, glibc-based Linux distribution designed for containers.

Before swapping anything, save a reference to the original image so we can compare later:

```sh
docker tag golang-hello golang-hello:ubuntu
```

#### What does the app actually need at runtime?

A replacement run image only has to provide what the app layers rely on:

**1. The same user.** Buildpacks never run your app as root:

```sh
docker run --rm --entrypoint id golang-hello
```

The app runs as `heroku` with UID/GID `1000`. The image config refers to this user by name, and rebase doesn't change it, so the new run image needs a `heroku` user with the same UID/GID.

**2. `bash`.** The Procfile process `web: golang-hello` is started as `bash -c golang-hello`.

**3. glibc.** Let's check which libraries the Go binary links against:

```sh
docker run --rm --entrypoint launcher golang-hello \
  bash -c 'ldd "$(command -v golang-hello)"'
```

The binary depends on `libc.so.6`, i.e. glibc. That's why we use Wolfi instead of Alpine, which ships `musl` and can't run this binary.

#### Building the Wolfi run image

Capture the UID/GID from the original image so that the new run image matches it exactly:

```sh
CNB_USER_ID=$(docker run --rm --entrypoint id golang-hello -u)
CNB_GROUP_ID=$(docker run --rm --entrypoint id golang-hello -g)
```

Now write a minimal run image definition and build it:

```sh
mkdir -p ~/wolfi-run && cd ~/wolfi-run

cat > Dockerfile.run <<'EOF'
FROM cgr.dev/chainguard/wolfi-base:latest

ARG CNB_USER_ID
ARG CNB_GROUP_ID

RUN apk add --no-cache bash \
 && addgroup -g ${CNB_GROUP_ID} heroku \
 && adduser -D -u ${CNB_USER_ID} -G heroku -s /bin/bash heroku

ENV CNB_USER_ID=${CNB_USER_ID} \
    CNB_GROUP_ID=${CNB_GROUP_ID}
USER ${CNB_USER_ID}:${CNB_GROUP_ID}

LABEL io.buildpacks.base.distro.name="wolfi"
EOF

docker build -f Dockerfile.run \
  --build-arg CNB_USER_ID=${CNB_USER_ID} \
  --build-arg CNB_GROUP_ID=${CNB_GROUP_ID} \
  -t golang-hello-run:wolfi .
```

::simple-task
---
:tasks: tasks
:name: build_wolfi_run_image
---
#active
please build the `golang-hello-run:wolfi` run image.

#completed
`golang-hello-run:wolfi` run image was built.
::

#### Rebasing

Swap Ubuntu for Wolfi underneath our app:

```sh
pack rebase golang-hello \
  --run-image golang-hello-run:wolfi \
  --pull-policy never \
  --force
```

* `--pull-policy never` uses the run image from the local Docker daemon instead of a registry.
* `--force` is needed because `pack` refuses to rebase onto a different distro (`ubuntu` → `wolfi`) by default. We've checked that our app only needs glibc, `bash` and a `heroku` user, so it's safe here.

The command finishes in a second or two because nothing is being built. `pack` only rewrites the image manifest so that the app layers sit on top of the new base layers.

::simple-task
---
:tasks: tasks
:name: rebase_golang_image
---
#active
please rebase the golang-hello image onto `golang-hello-run:wolfi`.

#completed
golang-hello image was rebased onto Wolfi.
::

#### Comparing the results

```sh
docker images golang-hello
```

```
IMAGE                 ID             DISK USAGE   CONTENT SIZE   EXTRA
golang-hello:latest   9ef0040fee5e       34.8MB             0B
golang-hello:ubuntu   c876d7cab8b6        564MB             0B
```

From 564MB down to about 35MB, with exactly the same app layers. Now scan both images:

```sh
trivy image --table-mode summary golang-hello:ubuntu
trivy image --table-mode summary golang-hello:latest
```

The OS package findings drop from over 300 (Ubuntu) to zero (Wolfi). The remaining findings are in the CNB `launcher` binary, which is part of the app layers, so a new base image can't fix them.

Finally, make sure that the app still works:

```sh
docker run -p 8080:8080 golang-hello
```

```sh
curl localhost:8080
```

#### When does this work?

Rebase works here because our app barely depends on the base image. Keep in mind:

* **The new base must be compatible.** It needs the same C library (glibc here) at the same or a newer version. Alpine would break this binary. Rebasing within the same distro, e.g. to pick up security patches, is the everyday use case and doesn't need `--force`.
* **`--force` turns off the safety net.** Always run the rebased image before you ship it.
* **You own the run image.** You are responsible for keeping it patched.
