#!/bin/bash

# add add-apt-repository
sudo apt install software-properties-common

# install pack-cli
sudo add-apt-repository ppa:cncf-buildpacks/pack-cli
sudo apt-get update
sudo apt-get install pack-cli
