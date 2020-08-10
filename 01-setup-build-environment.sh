#!/bin/bash
# for some reason, the root partition does use the whole disk by default
# sudo lvextend -l 100%FREE /dev/mapper/fedora-root00
# sudo xfs_growfs /dev/mapper/fedora-root00
# sudo sysctl -w fs.file-max=100000

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

# get some dependencies
cd ovirt-4.4-src
curl -Olk https://resources.ovirt.org/pub/ovirt-4.3/rpm/el7Workstation/SRPMS/ovirt-engine-yarn-1.7.0-1.el7.src.rpm

# get the SOURCES files
cd /home/cindy/rpmbuild/SOURCES/
ls ../../ovirt-4.4-src/ | awk '{print "rpm2cpio ../../ovirt-4.4-src/"$1" | cpio -ivd"}' > get-sources.sh
bash -x get-sources.sh

# get the .spec files
 mkdir ovirt-4.4-spec
 cd ovirt-4.4-spec/
 ls ../ovirt-4.4-src/ | awk '{print "rpm2cpio ../ovirt-4.4-src/"$1" | cpio -ivd"}' > get-specs.sh
 bash -x get-specs.sh
 
# patch the .spec files
sed 's/Source0.*/Source0\:\ yarn-offline-cache.tar/' -i ovirt-engine-nodejs-modules.spec
sed 's/\%..yarn./yarn-1.22.0.js/' -i ovirt-engine-nodejs-modules.spec

sed 's/BuildRequires.*automake/BuildRequires\:\ \ automake\nBuildRequires\:\ \ gcc/' -i ioprocess.spec

sed 's/BuildRequires: systemd/BuildRequires: systemd\nBuildRequires: python3-six/' -i mom.spec

# locales requires more file descriptors, sysctl results in read-only filesystem
sed 's/ovirt_build_locales\ 1/ovirt_build_locales\ 0/' -i ovirt-engine.spec

# requires gwt 
sed 's/ovirt_build_gwt 1/ovirt_build_gwt 0/' -i ovirt-engine.spec

# grep -B1 java-11 ovirt-engine-dwh.spec 
#        PY_VERSION=%{py_version} \\\
#        JAVA_DIR=/usr/lib/jvm/java-11/ \\\
# --
# %build
# export JAVA_HOME=/usr/lib/jvm/java-11/
sed 's/ovirt_build_all_user_agents 1/ovirt_build_all_user_agents 0/' -i ovirt-engine.spec
# build the patched SRPMs
ls | grep \.spec$ | awk '{print "rpmbuild -bs "$1}' > build-SRPMs.sh
bash -x build-SRPMs.sh


# list the available environments: ls -alhrt /etc/mock/f*

# initialize the mock sandbox
mock -r fedora-32-x86_64 --init

# finding problem packages
# ls /home/cindy/rpmbuild/SRPMS/ | grep rpm$ | awk '{print "mock -r fedora-32-x86_64 rebuild /home/cindy/rpmbuild/SRPMS/"$1" --resultdir /var/lib/mock/"$1}' > find-build-errors.sh
# bash -x find-build-errors.sh > find-build-errors.log 2>&1

# create the repo directory
sudo mkdir -p /var/repo/{noarch,x86_64}

# Build cockpit-ovirt
mock -r fedora-32-x86_64 --chain ovirt-engine-nodejs-modules-2.0.30-1.fc32.src.rpm cockpit-ovirt-0.14.10-1.fc32.src.rpm
find /var/lib/mock/fedora-32-x86_64/root/ | grep noarch'\.'rpm$ | awk '{print "mv "$1" /var/repo/noarch"}' > mv-noarch.sh
bash -x mv-noarch.sh
mock -r fedora-32-x86_64 clean
mock -r fedora-32-x86_64 init

mock -r fedora-32-x86_64 engine-db-query-1.6.1-1.fc32.src.rpm
find /var/lib/mock/fedora-32-x86_64/root/ | grep noarch'\.'rpm$ | awk '{print "mv "$1" /var/repo/noarch"}' > mv-noarch.sh
mock -r fedora-32-x86_64 --clean && mock -r fedora-32-x86_64 --init
mock -r fedora-32-x86_64 go-ovirt-engine-sdk4-4.4.1-1.fc32.src.rpm
find /var/lib/mock/fedora-32-x86_64/root/ | grep x86_64'\.'rpm$ | awk '{print "mv "$1" /var/repo/x86_64"}' > mv-x86_64.sh
bash -x mv-x86_64.sh

mock -r fedora-32-x86_64 --clean && mock -r fedora-32-x86_64 --init
mock -r fedora-32-x86_64 imgbased-1.2.10-0.1.fc32.src.rpm
find /var/lib/mock/fedora-32-x86_64/root/ | grep noarch'\.'rpm$ | awk '{print "mv "$1" /var/repo/noarch"}' > mv-noarch.sh

mock -r fedora-32-x86_64 ioprocess-1.4.1-1.fc32.src.rpm
find /var/lib/mock/fedora-32-x86_64/root/ | grep x86_64'\.'rpm$ | awk '{print "mv "$1" /var/repo/x86_64"}' > mv-x86_64.sh
bash -x mv-x86_64.sh

# mock -r fedora-32-x86_64 java-client-kubevirt-0.5.0-1.fc32.src.rpm
# has java build issues skip it to see if it's really needed

mock -r fedora-32-x86_64 java-ovirt-engine-sdk4-4.4.3-1.fc32.src.rpm
find /var/lib/mock/fedora-32-x86_64/root/ | grep noarch'\.'rpm$ | awk '{print "mv "$1" /var/repo/noarch"}' > mv-noarch.sh
bash -x mv-noarch.sh 

# mock -r fedora-32-x86_64 mingw-spice-vdagent-0.9.0-2.fc32.src.rpm
# took a really long time skip it to see if it's really needed

mock -r fedora-32-x86_64 mom-0.6.0-1.fc32.src.rpm 
find /var/lib/mock/fedora-32-x86_64/root/ | grep noarch'\.'rpm$ | awk '{print "mv "$1" /var/repo/noarch"}' > mv-noarch.sh
bash -x mv-noarch.sh 
  
mock -r fedora-32-x86_64 --clean && mock -r fedora-32-x86_64 --init
mock -r fedora-32-x86_64 otopi-1.9.2-1.fc32.src.rpm
find /var/lib/mock/fedora-32-x86_64/root/ | grep noarch'\.'rpm$ | awk '{print "mv "$1" /var/repo/noarch"}' > mv-noarch.sh
bash -x mv-noarch.sh
  
mock -r fedora-32-x86_64 ovirt-ansible-cluster-upgrade-1.2.3-1.fc32.src.rpm
find /var/lib/mock/fedora-32-x86_64/root/ | grep noarch'\.'rpm$ | awk '{print "mv "$1" /var/repo/noarch"}' > mv-noarch.sh
bash -x mv-noarch.sh
find /var/lib/mock/fedora-32-x86_64/root/ | grep noarch'\.'rpm$ | awk '{print "mv "$1" /var/repo/noarch"}' > mv-noarch.sh
bash -x mv-noarch.sh 
history
mock -r fedora-32-x86_64 ovirt-ansible-disaster-recovery-1.3.0-1.fc32.src.rpm
find /var/lib/mock/fedora-32-x86_64/root/ | grep noarch'\.'rpm$ | awk '{print "mv "$1" /var/repo/noarch"}' > mv-noarch.sh
bash -x mv-noarch.sh 
mock -r fedora-32-x86_64 ovirt-ansible-engine-setup-1.2.4-1.fc32.src.rpm
find /var/lib/mock/fedora-32-x86_64/root/ | grep noarch'\.'rpm$ | awk '{print "mv "$1" /var/repo/noarch"}' > mv-noarch.sh
bash -x mv-noarch.sh 
mock -r fedora-32-x86_64 --clean && mock -r fedora-32-x86_64 --init
mock -r fedora-32-x86_64 ovirt-ansible-hosted-engine-setup-1.1.7-1.fc32.src.rpm
find /var/lib/mock/fedora-32-x86_64/root/ | grep noarch'\.'rpm$ | awk '{print "mv "$1" /var/repo/noarch"}' > mv-noarch.sh
bash -x mv-noarch.sh 
mock -r fedora-32-x86_64 --clean && mock -r fedora-32-x86_64 --init
mock -r fedora-32-x86_64 ovirt-ansible-image-template-1.2.2-1.fc32.src.rpm
find /var/lib/mock/fedora-32-x86_64/root/ | grep noarch'\.'rpm$ | awk '{print "mv "$1" /var/repo/noarch"}' > mv-noarch.sh
bash -x mv-noarch.sh 
mock -r fedora-32-x86_64 --clean && mock -r fedora-32-x86_64 --init
mock -r fedora-32-x86_64 ovirt-ansible-infra-1.2.1-1.fc32.src.rpm
find /var/lib/mock/fedora-32-x86_64/root/ | grep noarch'\.'rpm$ | awk '{print "mv "$1" /var/repo/noarch"}' > mv-noarch.sh
bash -x mv-noarch.sh 
mock -r fedora-32-x86_64 --clean && mock -r fedora-32-x86_64 --init
mock -r fedora-32-x86_64 ovirt-ansible-manageiq-1.2.1-1.fc32.src.rpm
find /var/lib/mock/fedora-32-x86_64/root/ | grep noarch'\.'rpm$ | awk '{print "mv "$1" /var/repo/noarch"}' > mv-noarch.sh
bash -x mv-noarch.sh 
mock -r fedora-32-x86_64 --clean && mock -r fedora-32-x86_64 --init
mock -r fedora-32-x86_64 ovirt-ansible-repositories-1.2.4-1.fc32.src.rpm
find /var/lib/mock/fedora-32-x86_64/root/ | grep noarch'\.'rpm$ | awk '{print "mv "$1" /var/repo/noarch"}' > mv-noarch.sh
bash -x mv-noarch.sh 
mock -r fedora-32-x86_64 --clean && mock -r fedora-32-x86_64 --init
mock -r fedora-32-x86_64 ovirt-ansible-roles-1.2.3-1.fc32.src.rpm
find /var/lib/mock/fedora-32-x86_64/root/ | grep noarch'\.'rpm$ | awk '{print "mv "$1" /var/repo/noarch"}' > mv-noarch.sh
bash -x mv-noarch.sh 
mock -r fedora-32-x86_64 --clean && mock -r fedora-32-x86_64 --init
mock -r fedora-32-x86_64 ovirt-ansible-shutdown-env-1.0.4-1.fc32.src.rpm
find /var/lib/mock/fedora-32-x86_64/root/ | grep noarch'\.'rpm$ | awk '{print "mv "$1" /var/repo/noarch"}' > mv-noarch.sh
bash -x mv-noarch.sh 
mock -r fedora-32-x86_64 --clean && mock -r fedora-32-x86_64 --init
mock -r fedora-32-x86_64 ovirt-ansible-vm-infra-1.2.3-1.fc32.src.rpm
find /var/lib/mock/fedora-32-x86_64/root/ | grep noarch'\.'rpm$ | awk '{print "mv "$1" /var/repo/noarch"}' > mv-noarch.sh
bash -x mv-noarch.sh
# missing pom https://repo1.maven.org/maven2/com/google/gwt/gwt/2.8.0/gwt-2.8.0.pom
# ovirt-engine-4.4.1.10-1.fc32

mock -r fedora-32-x86_64 --clean && mock -r fedora-32-x86_64 --init
mock -r fedora-32-x86_64 ovirt-engine-dwh-4.4.1.2-1.fc32.src.rpm
  581  sudo find /var/lib/mock/fedora-32-x86_64/root/ | grep noarch'\.'rpm$ | awk '{print "mv "$1" /var/repo/noarch"}' > mv-noarch.sh
  582  sudo bash -x mv-noarch.sh
mock -r fedora-32-x86_64 --clean && mock -r fedora-32-x86_64 --init
mock -r fedora-32-x86_64 ovirt-engine-yarn-1.7.0-1.fc32.src.rpm 
find /var/lib/mock/fedora-32-x86_64/root/ | grep noarch'\.'rpm$ | awk '{print "mv "$1" /var/repo/noarch"}' > mv-noarch.sh
bash -x mv-noarch.sh

 mock -r fedora-32-x86_64 --clean && mock -r fedora-32-x86_64 --init
  534  mock -r fedora-32-x86_64 --chain ovirt-engine-nodejs-modules-2.0.30-1.fc32.src.rpm  ovirt-engine-api-explorer-0.0.6-1.fc32.src.rpm
  535  sudo find /var/lib/mock/fedora-32-x86_64/root/ | grep noarch'\.'rpm$ | awk '{print "mv "$1" /var/repo/noarch"}' > mv-noarch.sh
  536  sudo bash -x mv-noarch.sh
mock -r fedora-32-x86_64 --clean && mock -r fedora-32-x86_64 --init
  546  mock -r fedora-32-x86_64 --chain ovirt-engine-extensions-api-1.0.1-1.fc32.src.rpm ovirt-engine-extension-aaa-jdbc-1.2.0-1.fc32.src.rpm
  549  sudo find /var/lib/mock/fedora-32-x86_64/root/ | grep noarch'\.'rpm$ | awk '{print "mv "$1" /var/repo/noarch"}' > mv-noarch.sh
  550  sudo bash -x mv-noarch.sh
  555  mock -r fedora-32-x86_64 --chain ovirt-engine-extensions-api-1.0.1-1.fc32.src.rpm ovirt-engine-extension-aaa-ldap-1.4.0-1.fc32.src.rpm
  556  sudo find /var/lib/mock/fedora-32-x86_64/root/ | grep noarch'\.'rpm$ | awk '{print "mv "$1" /var/repo/noarch"}' > mv-noarch.sh
  557  sudo bash -x mv-noarch.sh
mock -r fedora-32-x86_64 --chain ovirt-engine-extensions-api-1.0.1-1.fc32.src.rpm ovirt-engine-extension-aaa-misc-1.1.0-1.fc32.src.rpm
  561  sudo find /var/lib/mock/fedora-32-x86_64/root/ | grep noarch'\.'rpm$ | awk '{print "mv "$1" /var/repo/noarch"}' > mv-noarch.sh
  562  sudo bash -x mv-noarch.sh
mock -r fedora-32-x86_64 --chain ovirt-engine-extensions-api-1.0.1-1.fc32.src.rpm ovirt-engine-extension-logger-log4j-1.1.0-1.fc32.src.rpm
  566  sudo find /var/lib/mock/fedora-32-x86_64/root/ | grep noarch'\.'rpm$ | awk '{print "mv "$1" /var/repo/noarch"}' > mv-noarch.sh
  567  sudo bash -x mv-noarch.sh
mock -r fedora-32-x86_64 ovirt-engine-extensions-api-1.0.1-1.fc32.src.rpm
find /var/lib/mock/fedora-32-x86_64/root/ | grep noarch'\.'rpm$ | awk '{print "mv "$1" /var/repo/noarch"}' > mv-noarch.sh
  567  sudo bash -x mv-noarch.sh
mock -r fedora-32-x86_64 ovirt-engine-nodejs-modules-2.0.30-1.fc32.src.rpm
mock -r fedora-32-x86_64 --chain ovirt-engine-nodejs-modules-2.0.30-1.fc32.src.rpm ovirt-engine-ui-extensions-1.2.2-1.fc32.src.rpm
  593  sudo find /var/lib/mock/fedora-32-x86_64/root/ | grep noarch'\.'rpm$ | awk '{print "mv "$1" /var/repo/noarch"}' > mv-noarch.sh
  594  sudo bash -x mv-noarch.sh
mock -r fedora-32-x86_64 ovirt-host-4.4.1-4.fc32.src.rpm
  602  sudo find /var/lib/mock/fedora-32-x86_64/root/ | grep x86_64'\.'rpm$ | awk '{print "mv "$1" /var/repo/x86_64"}' > mv-x86_64.sh
  603  sudo bash -x mv-x86_64.sh
# ovirt depends on ovirt-engine-yarn
sudo mv /var/lib/mock/fedora-32-x86_64/result/*.noarch.rpm /var/repo/noarch/

# Reference:
#   Setting up mock env
#   https://blog.packagecloud.io/eng/2015/05/11/building-rpm-packages-with-mock/
#   How to use mock --chain
#   https://github.com/rpm-software-management/mock/issues/267
