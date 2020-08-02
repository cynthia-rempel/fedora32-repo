#!/bin/bash
# Get the source to build the packages with
mkdir SRPMS
cd SRPMS
wget -r -A .rpm https://resources.ovirt.org/pub/ovirt-4.4/rpm/el8/SRPMS/ --reject appliance
