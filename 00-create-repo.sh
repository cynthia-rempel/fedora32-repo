#!/bin/bash

# configure fedora32 to trust fedora32 packages
sudo rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-32-x86_64

# install packages
sudo dnf install createrepo httpd mock rpm-build yum-utils

# create the repo directory
sudo mkdir -p /var/repo

# finally once the packages are added, run create repo

# set the service to start on reboot and now
sudo systemctl enable httpd
sudo systemctl start httpd
# Using repo locally so not allowing the traffic through
# firewall-cmd --zone=public --permanent --add-service=http
# firewall-cmd --zone=public --permanent --add-service=https
# firewall-cmd --reload

# install the .repo file

# test the repo by installing packages

# References:
#   https://www.redhat.com/sysadmin/apache-yum-dnf-repo
