#!/bin/bash

rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-32-x86_64
# Add and configure a 'clean-room' to create the packages in
dnf -y install mock
usermod -a -G mock cindy

# Reference:
#   https://blog.packagecloud.io/eng/2015/05/11/building-rpm-packages-with-mock/
