#!/bin/bash
cd rpmbuild/SOURCES
wget https://dl.fedoraproject.org/pub/epel/7/x86_64/Packages/p/python-ioprocess-0.15.1-1.el7.noarch.rpm
# Get the source to build the packages with
sudo cp 11-packages.repo /etc/yum.repos.d/
reposync -n --source --repo ovirt-4.4-src  --newest-only

# TODO: exclude appliance and NodeJS packages
