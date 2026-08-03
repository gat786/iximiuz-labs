---
kind: tutorial

title: |-
  What are buildpacks, understanding the usecases, benefits and capabilities

description: |-
  This is a sample tutorial that demonstrates main capabilities of the iximiuz Labs content management system.

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
# tasks:
#   init_task_1:
#     init: true
#     run: ...
#   regular_task_1:
#     run: ...
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

Buildpacks is a CNCF project which aims at enabling building container images
by analysing context that is provided to it and without there being a need for
a Dockerfile. Buildpacks when used actually look into the codebase (build
context) and `detect` the type of codebase it is, i.e. detect language it is
written in, detect the type of application (web-service, api, serverless) and
different metadata such as versions of sdks, special custom buildpack
declarations made and based up on all of this (probably a lot of other factors
as well) decide a particular order in which an image should be build, build it
and make it available to your local docker runtime. The image thus built can be
pushed to any OCI compatible registry i.e. (DockerHub, Google Cloud Artifact
Registry, Github Container Registry etc) and then pulled from your container
orchestrator to be executed.

### Benefits of using Buildpacks

The main benefits of using Buildpacks are as follows

1. **No Containerfiles to manage** - You don't need to maintain a separate
  Containerfile anywhere which describes how your application should be build.
  Buildpacks read the context i.e. your source code and automatically pick
  up finer details of your application and create run time image accordingly.

    *  **No more worrying about incorrect Containerfile** - Since there are no
    Containerfiles to begin with, it removes a whole class of bugs that comes
    with managing it, a lot of times applications change, their source codes
    change people start using newer versions of languages for example of
    developing but Containerfiles remain the same making it so that there is a
    drift created unknowingly which may lead to an application failing to start
    at some point when the drift starts breaking software.

    *  **Up and running in no time** If your workload is a standard workload for
    which definitions of buildpacks and builders already exists, you only need the
    `pack` cli to automate building of images. It gives a quick start to a tech
    team just beginning to create their infrastructure which they can later
    optimise as they want.

    * **Containerized Workloads from the get go** which is a big win for any
    platform teams looking to onboard a new compute option which uses cloud-native
    deployment techniques like a container-runtime.

2. **Flexibility of changing base layers of runtime image** You get
  flexibility of using `rebase` feature. It is a feature that allows on demand
  of swapping base layer of any pre-built runtime container image without running
  the entire build pipeline. This feature allows you rebuilt images quickly for

    * Patching images that have critical vulnerabilities in them.
    * Updating base layer of runtime image with newer software when available
    even for software that was built a long time ago, this allows fixing of runtime
    container images created by buildpacks with matching base layer images.


### What is it not?

* It is not a replacement for standard ways to build a container.
* It does not always produce the most optimised container image.
* It will not always work out of the box for your custom source code structure.


## How does it differ from standard way of creating containers?

Standard way of containerizing applications is as follows

1. You write your application code.
2. You write a Containerfile definition.
3. You use the docker CLI to create a container depending upon the
containerfile which was defined.

For example, lets start the playground, we will see an example.

## Going hands on

### Building a standard Nodejs application using Dockerfiles

if you see the currently started playgrounds home directory you will find that
there is a directory called `examples/` within which there are 3 different
directories each containing an example rest api application written in 3 different
languages.

Lets try building the application which is inside the directory named
`examples/nodejs-hello`. Lets start by analysing whats inside the codebase
inorder to make sure you understand what we are dealing with, it is a very simple
web app written such that we can demonstrate building a container. You can see
file contents in the below tab.


::tabbed
---
tabs:
  - name: tab1
    title: index.js
  - name: tab2
    title: package.json
group: buildpack-files
---
#tab1
```js
const express = require('express');

const app = express();
const port = process.env.PORT || 8080;

app.get('/', (req, res) => {
  res.send('Hello from the Node.js buildpack example!');
});

app.get('/healthz', (req, res) => {
  res.json({ status: 'ok' });
});

app.listen(port, () => {
  console.log(`Server listening on port ${port}`);
});

```

#tab2

```json
{
  "name": "nodejs-hello",
  "version": "1.0.0",
  "private": true,
  "description": "Minimal Express hello-world app for a Cloud Native Buildpacks tutorial",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "engines": {
    "node": ">=22 <25"
  },
  "dependencies": {
    "express": "^4.19.2"
  }
}
```
::

We can see that it is a simple example of a rest api using `express` library
from [npmjs](https://npmjs.com) and is a very simple application to build.

Lets create a dockerfile for it.

```bash
cat >> Dockerfile << "DOCKERFILE"
FROM node:22-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --omit=dev

COPY . .

ENV PORT=8080
EXPOSE 8080

USER node

CMD ["npm", "start"]
DOCKERFILE
```

Now if you build an image, using the build command you will be able to run it.

```
docker build . -t nodejs-hello
docker run -p 8080:8080 nodejs-hello
```

### Trying out buildpacks

This playground comes preinstalled with `pack` cli, which is the most common
and used way of building container images with buildpacks. It is a tool which
orchestrates the process of building the images using `builders`, `buildpacks`
using build `lifecycle` of buildpacks.

Lets try using it

```bash
pack
```

You will see a lot of options when you run this command, some useful, some not
so much. Lets go over the most important things before we use the tool.

#### Builder

A Buildpack Builder is an OCI image that consists of a bunch of things that make
a build process successful, namely `lifecycle` binary, `buildpack definitions`
references to `build` and `run` docker images. When building a container image
using buildpacks, one can specify a builder and builder will run the lifecycle
binary along with it the definitions of buildpacks will run and depending upon
whether operation was a success you will end up generating a container image.

#### Buildpack Definitions

Buildpack definitions are nothing but scripts that get executed and complete a
certain part of the lifecycle of the build process. For example typically simplest
buildpack definitions implement `detect` and `build` phases. In the `detect` phase
the definition should `detect` if the `build` process should even run or not,
if it should run then the `detect` phase should collect necessary information for
`build` to successfully happen and pass it to the `build` process.

::remark-box
---
kind: info
---
We will go in more details about the builder and buildpack definitions in an upcoming
tutorial.
::

Inorder to build our first container image using pack, we need to specify a
builder and provide the necessary build context (i.e. source code directory)

```sh
pack build \
  --builder paketobuildpacks/ubuntu-resolute-builder \
  nodejs-hello
```

Doing this will pull the builder, run all the buildpack definitions that are
configured in that builder and then supported buildpacks did end up running
the builder phase of it.


Docs: [How to Author Tutorials on iximiuz Labs](/tutorials/sample-tutorial)

(place your tutorial content here)
