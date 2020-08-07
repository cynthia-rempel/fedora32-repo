#!/bin/bash
# for some reason, the root partition does use the whole disk by default
# sudo lvextend -l 100%FREE /dev/mapper/fedora-root00
# sudo xfs_growfs /dev/mapper/fedora-root00

rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-32-x86_64
# Add and configure a 'clean-room' to create the packages in
dnf -y install mock rpm-build
usermod -a -G mock cindy

# add the source repo
tee -a /etc/yum.repos.d/ovirt-src.repo << END
[ovirt-4.4-src]
name=Latest oVirt 4.4 Release
baseurl=https://resources.ovirt.org/pub/ovirt-4.4/rpm/el8/SRPMS/
enabled=0
gpgcheck=0
END

# at last, mirror the source RPMs
reposync -n --source --repo ovirt-4.4-src  --newest-only

# get the SOURCES files
cd /home/cindy/rpmbuild/SOURCES/
ls ../../ovirt-4.4-src/ | awk '{print "rpm2cpio ../../ovirt-4.4-src/"$1" | cpio -ivd"}' > get-sources.sh
bash -x get-sources.sh

# get the .spec files
 mkdir ovirt-4.4-spec
 cd ovirt-4.4-spec/
 ls ../ovirt-4.4-src/ | awk '{print "rpm2cpio ../ovirt-4.4-src/"$1" | cpio -ivd"}' > get-specs.sh
 
# list the available environments: ls -alhrt /etc/mock/f*

# initialize the mock sandbox
mock -r fedora-32-x86_64 --init
# Reference:
#   https://blog.packagecloud.io/eng/2015/05/11/building-rpm-packages-with-mock/
