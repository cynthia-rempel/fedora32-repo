#!/bin/bash
# Get the source to build the packages with
sudo dnf localinstall ovirt-release44.rpm
mkdir SRPMS
cd SRPMS
wget -r -A .rpm https://resources.ovirt.org/pub/ovirt-4.4/rpm/el8/SRPMS/ --reject appliance
