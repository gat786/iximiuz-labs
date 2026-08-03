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

      wget https://github.com/gat786/iximiuz-labs/releases/download/release-19/examples.zip
      unzip examples.zip
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

## How does it differ from standard way of creating containers?

Standard way of containerizing applications is as follows

1. You write your application code.
2. You write a Containerfile definition.
3. You use the docker CLI to create a container depending upon the
containerfile which was defined.

For example, lets start the playground, we will see an example.

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

Docs: [How to Author Tutorials on iximiuz Labs](/tutorials/sample-tutorial)

(place your tutorial content here)
