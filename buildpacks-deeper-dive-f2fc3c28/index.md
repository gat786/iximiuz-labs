---
kind: tutorial

title: |-
  Buildpacks - Going deeper, understanding context changes, rebasing images

description: |-
  This is a sample tutorial that demonstrates main capabilities of the iximiuz Labs content management system.

categories:
- linux
- containers

tagz:
- docker
- container-image

createdAt: 2026-08-03
updatedAt: 2026-08-03

cover: __static__/cover.png


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
---

#### Builder

A Buildpack Builder is an OCI image that consists of

* [`lifecycle`](https://github.com/buildpacks/lifecycle) binary which is the binary
that orchestrates the build process.

* `buildpack definitions` (sometimes one, sometimes multiple) (they are what
defines the build process).

* reference to `build container image` (the container in which build process
happens). The build container image should support all the actions that are
defined in a `buildpack definition`, i.e. for example - if a
`buildpack definition` uses `jq` to parse some `yaml` file to get information
about a file in context, build image should have `yq` present in it.

* reference to `run-time container image` (the container image on which
after built layers are attached and which forms the final run time image).


::remark-box
---
kind: info
---
Lifecycle binary is an implementation of the [Cloud Native Buildpacks
Specification](https://github.com/buildpacks/spec). You do not have to configure
it to use buildpacks generally, you need to use its features in the buildpacks
definitions to create proper building stage. We will learn more about lifecycle
in a different tutorial.
::

#### Buildpack Definitions

Buildpack definitions are nothing but scripts that get executed and complete a
certain part of the lifecycle of the build process. For example typically simplest
buildpack definitions implement `detect` and `build` phases. In the `detect` phase
the definition should `detect` if the `build` process should even run or not,
if it should run then the `detect` phase should collect necessary information for
`build` to successfully happen and pass it to the `build` process.

Buildpack definitions are packaged in a builder and when you run pack build
with a builder, it automatically runs all of the buildpack definitions that
are packaged in it, and then the definitions which pass the `detect` phase get
ahead to run the `build` phase.

_This is a sample tutorial that demonstrates main capabilities of the iximiuz Labs content management system._

Docs: [How to Author Tutorials on iximiuz Labs](/tutorials/sample-tutorial)

(place your tutorial content here)
