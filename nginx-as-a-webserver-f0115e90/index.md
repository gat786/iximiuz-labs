---
kind: tutorial

title: |-
  Nginx - How to set it up and use it as a webserver

description: |-
  This is a sample tutorial that demonstrates usage of Nginx as a standard webserver

categories:
- linux
- networking

tagz:
- webserver
- nginx

createdAt: 2026-09-10
updatedAt: 2026-09-10

# cover: __static__/cover.png


# Uncomment to embed (one or more) challenges.
# challenges:
#   challenge_name_1: {}
#   challenge_name_2: {}

playground: ubuntu-26-04

# Uncomment to add (one or more) background tasks.
tasks:
  install_nginx:
    init: false
    regular: true
    run: |
      sudo apt-get install nginx -y

  backup_default_conf:
    regular: true
    run: |
      sudo mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak

  create_new_conf:
    regular: true
    run: |
      sudo touch /etc/nginx/nginx.conf

  setup_simplest_conf:
    run: |
      sudo cat <<EOF > /etc/nginx/nginx.conf
      http {
        server {
          listen 80;
        }
      }

      events {}
      EOF

  call_port_80:
    run: |
      curl localhost
#   regular_task_1:
#     run: ...
---

## What is Nginx

Nginx is a popular open-source webserver and proxy software that can be used to
server over the world wide web. In this tutorial we will see how to install it, use it and configure it as a webserver to serve any static content that we might want to serve.

Let's start by installing nginx -

```
sudo apt-get install nginx
```

::simple-task
---
:tasks: tasks
:name: install_nginx
---
#active
waiting for the user to install nginx

#completed
nginx has been successfully installed
::

Nginx is configured using a configuration file. It is a text file that lives in `/etc/nginx/nginx.conf`. We need to configure nginx so that we can expose the content we want using it as a webserver. Let's start by renaming the default config as `nginx.conf.bak` (so that we still have the default config as a backup file) and creating a blank file with the following content.

::simple-task
---
:tasks: tasks
:name: backup_default_conf
---
#active
waiting for the default config to be backed up to nginx.conf.bak file

#completed
default config has been backed up
::

::simple-task
---
:tasks: tasks
:name: create_new_conf
---
#active
waiting for the new nginx.conf file to be created

#completed
A new nginx.conf file has been created
::

```bash
sudo cat <<EOF > /etc/nginx/nginx.conf
http {
  server {
    listen 80;
  }
}

events {}
```

What you are seeing above is the simplest Nginx configuration that you can have and what it does is, expose an `http` webserver on port `80`. Once you have made that change, you can start up nginx by running the command

```
nginx
```

We did not define any content that will be available on port `80`. Lets start by seeing what nginx serves by default.

```
curl localhost
```
::simple-task
---
:tasks: tasks
:name: call_port_80
---
#active
waiting for the user to curl localhost

#completed
default content has been explored.
::
