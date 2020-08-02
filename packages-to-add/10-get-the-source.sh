#!/bin/bash
# Get the source to build the packages with
sudo cp 11-packages.repo /etc/yum.repos.d/
reposync -n --source --repo ovirt-4.4-src  --newest-only

# TODO: exclude appliance and NodeJS packages
