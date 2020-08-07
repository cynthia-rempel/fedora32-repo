#!/bin/bash
cd rpmbuild/SOURCES

# Get the source to build the packages with
sudo cp 11-packages.repo /etc/yum.repos.d/
reposync -n --source --repo ovirt-4.4-src  --newest-only
# wget http://vault.centos.org/7.8.2003/os/Source/SPackages/cracklib-2.9.0-11.el7.src.rpm
# TODO: exclude appliance package
