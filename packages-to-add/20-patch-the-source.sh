# Placeholder to acknowledge the patching step
# This is a first-pass to identify some things that need patching and order of a workingish install of rpms
# TODO: re-run using mock

# identify which packages need to be installed for a build to succeed
sudo yum-builddep ./*.rpm > log.txt 2>&1
grep matching log.txt | sort | uniq | awk '{print $6}'


# ovirt-engine-nodejs-modules
sudo yum-builddep ovirt-engine-nodejs-modules-2.0.30-1.el8.src.rpm
rpmbuild --rebuild ovirt-engine-nodejs-modules-2.0.30-1.el8.src.rpm
sed 's/Source0.*/Source0\:\ yarn-offline-cache.tar/' -i ../SPECS/ovirt-engine-nodejs-modules.spec
sed 's/\%..yarn./yarn-1.22.0.js/' -i ../SPECS/ovirt-engine-nodejs-modules.spec
# build the patched .spec
rpmbuild -bb ../SPECS/ovirt-engine-nodejs-modules.spec
# finally, test installing the patched RPM.
sudo dnf install ../RPMS/noarch/ovirt-engine-nodejs-modules-2.0.30-1.fc32.noarch.rpm

# the sources that need to be installed before others can be built
# 'mvn(org.ovirt.engine.api:ovirt-engine-extensions-api)'
# 'ovirt-engine-wildfly'
sudo yum-builddep ovirt-engine-wildfly-19.1.0-2.el8.src.rpm 
rpmbuild --rebuild ovirt-engine-wildfly-19.1.0-2.el8.src.rpm
sudo dnf install ../RPMS/x86_64/ovirt-engine-wildfly-19.1.0-2.fc32.x86_64.rpm

# 'ovirt-engine-yarn'
# there isn't a rpm in the 4.4 repo.  There's source though

# 'ovirt-jboss-modules-maven-plugin
sudo yum-builddep ovirt-jboss-modules-maven-plugin-2.0.2-0.1.el8.src.rpm 
sudo dnf install maven-release-plugin
rpmbuild --rebuild ovirt-jboss-modules-maven-plugin-2.0.2-0.1.el8.src.rpm
sudo dnf install ../RPMS/noarch/ovirt-jboss-modules-maven-plugin-2.0.2-0.1.el8.noarch.rpm 
sudo dnf install ../RPMS/noarch/ovirt-jboss-modules-maven-plugin-javadoc-2.0.2-0.1.el8.noarch.rpm

sudo yum-builddep python-ovirt-engine-sdk4-4.4.4-1.el8.src.rpm 
rpmbuild --rebuild python-ovirt-engine-sdk4-4.4.4-1.el8.src.rpm 
sudo dnf install ../RPMS/x86_64/python*

# ovirt-engine-extensions-api
sudo yum-builddep ovirt-engine-extensions-api-1.0.1-1.el8.src.rpm
sudo dnf install ../RPMS/noarch/ovirt-engine-extensions-api-*

# python3-ioprocess
sudo yum-builddep ioprocess-1.4.1-1.el8.src.rpm
rpmbuild --rebuild ioprocess-1.4.1-1.el8.src.rpm 
sudo dnf install ../RPMS/x86_64/ioprocess-*
sudo dnf install ../RPMS/x86_64/python3-ioprocess-1.4.1-1.fc32.x86_64.rpm

sudo yum-builddep otopi-1.9.2-1.el8.src.rpm 
rpmbuild --rebuild otopi-1.9.2-1.el8.src.rpm 
sudo dnf install ../RPMS/noarch/otopi-common-1.9.2-1.fc32.noarch.rpm 
sudo dnf install ../RPMS/noarch/python3-otopi-*
sudo dnf install ../RPMS/noarch/otopi-*

sudo yum-builddep engine-db-query-1.6.1-1.el8.src.rpm 
sudo dnf install python3-flake8 python3-tools
rpmbuild --rebuild engine-db-query-1.6.1-1.el8.src.rpm 
sudo dnf install ../RPMS/noarch/engine-db-query-1.6.1-1.fc32.noarch.rpm 

sudo yum-builddep go-ovirt-engine-sdk4-4.4.1-1.el8.src.rpm 
rpmbuild --rebuild go-ovirt-engine-sdk4-4.4.1-1.el8.src.rpm 
sudo dnf install ../RPMS/x86_64/go-ovirt-engine-sdk4-devel-4.4.1-1.fc32.x86_64.rpm

sudo yum-builddep imgbased-1.2.10-0.1.el8.src.rpm 
sudo dnf install python3-nose
rpmbuild --rebuild imgbased-1.2.10-0.1.el8.src.rpm 
sudo dnf install ../RPMS/noarch/imgbased-1.2.10-0.1.fc32.noarch.rpm 
sudo dnf install ../RPMS/noarch/python3-imgbased-1.2.10-0.1.fc32.noarch.rpm


sudo yum-builddep java-ovirt-engine-sdk4-4.4.3-1.el8.src.rpm 
rpmbuild --rebuild java-ovirt-engine-sdk4-4.4.3-1.el8.src.rpm 
sudo dnf install ../RPMS/noarch/java-ovirt-engine-sdk4-4.4.3-1.fc32.noarch.rpm

sudo yum-builddep safelease-1.0.1-2.el8.src.rpm 
rpmbuild --rebuild safelease-1.0.1-2.el8.src.rpm 
sudo dnf install ../RPMS/x86_64/safelease-*
  
sudo yum-builddep v2v-conversion-host-1.16.0-1.el8.src.rpm 
rpmbuild --rebuild v2v-conversion-host-1.16.0-1.el8.src.rpm 
sudo dnf install ../RPMS/noarch/v2v-conversion-host-*

sudo yum-builddep ovirt-ansible-cluster-upgrade-1.2.3-1.el8.src.rpm 
rpmbuild --rebuild ovirt-ansible-cluster-upgrade-1.2.3-1.el8.src.rpm 
sudo dnf install ../RPMS/noarch/ovirt-ansible-cluster-upgrade-1.2.3-1.fc32.noarch.rpm

sudo yum-builddep ovirt-ansible-disaster-recovery-1.3.0-1.el8.src.rpm 
rpmbuild --rebuild ovirt-ansible-disaster-recovery-1.3.0-1.el8.src.rpm 
sudo dnf install ../RPMS/noarch/ovirt-ansible-disaster-recovery-1.3.0-1.fc32.noarch.rpm

sudo yum-builddep ovirt-ansible-engine-setup-1.2.4-1.el8.src.rpm 
rpmbuild --rebuild ovirt-ansible-engine-setup-1.2.4-1.el8.src.rpm 
sudo dnf install ../RPMS/noarch/ovirt-ansible-engine-setup-1.2.4-1.fc32.noarch.rpm

sudo yum-builddep ovirt-ansible-hosted-engine-setup-1.1.7-1.el8.src.rpm 
rpmbuild --rebuild ovirt-ansible-hosted-engine-setup-1.1.7-1.el8.src.rpm 
sudo dnf install ../RPMS/noarch/ovirt-ansible-hosted-engine-setup-1.1.7-1.fc32.noarch.rpm

sudo yum-builddep ovirt-ansible-infra-1.2.1-1.el8.src.rpm 
rpmbuild --rebuild ovirt-ansible-infra-1.2.1-1.el8.src.rpm 
sudo dnf install ../RPMS/noarch/ovirt-ansible-infra-1.2.1-1.fc32.noarch.rpm

sudo yum-builddep ovirt-ansible-manageiq-1.2.1-1.el8.src.rpm 
rpmbuild --rebuild ovirt-ansible-manageiq-1.2.1-1.el8.src.rpm 
sudo dnf install ../RPMS/noarch/ovirt-ansible-manageiq-1.2.1-1.fc32.noarch.rpm 
rpmbuild --rebuild ovirt-ansible-repositories-1.2.4-1.el8.src.rpm 
sudo dnf install ../RPMS/noarch/ovirt-ansible-repositories-1.2.4-1.fc32.noarch.rpm 
rpmbuild --rebuild ovirt-ansible-roles-1.2.3-1.el8.src.rpm 
rpmbuild --rebuild ovirt-ansible-shutdown-env-1.0.4-1.el8.src.rpm 
rpmbuild --rebuild ovirt-ansible-vm-infra-1.2.3-1.el8.src.rpm 
sudo dnf install ../RPMS/noarch/ovirt-ansible-*

sudo yum-builddep ovirt-cockpit-sso-0.1.4-1.el8.src.rpm 
rpmbuild --rebuild ovirt-cockpit-sso-0.1.4-1.el8.src.rpm 
sudo yum install ../RPMS/noarch/ovirt-cockpit-sso-0.1.4-1.fc32.noarch.rpm

sudo yum-builddep ovirt-engine-extension-aaa-jdbc-1.2.0-1.el8.src.rpm 
rpmbuild --rebuild ovirt-engine-extension-aaa-jdbc-1.2.0-1.el8.src.rpm 
sudo dnf install ../RPMS/noarch/ovirt-engine-extension-aaa-jdbc-1.2.0-1.fc32.noarch.rpm

sudo yum-builddep ovirt-engine-extension-aaa-ldap-1.4.0-1.el8.src.rpm 
rpmbuild --rebuild ovirt-engine-extension-aaa-ldap-1.4.0-1.el8.src.rpm 
sudo dnf install ../RPMS/noarch/ovirt-engine-extension-aaa-ldap-*

sudo yum-builddep ovirt-engine-extension-aaa-misc-1.1.0-1.el8.src.rpm
rpmbuild --rebuild ovirt-engine-extension-aaa-misc-1.1.0-1.el8.src.rpm 
sudo dnf install ../RPMS/noarch/ovirt-engine-extension-aaa-misc-1.1.0-1.fc32.noarch.rpm

 sudo yum-builddep ovirt-engine-extension-logger-log4j-1.1.0-1.el8.src.rpm 
 rpmbuild --rebuild ovirt-engine-extension-logger-log4j-1.1.0-1.el8.src.rpm 
 sudo dnf install ../RPMS/noarch/ovirt-engine-extension-logger-log4j-1.1.0-1.fc32.noarch.rpm 
 
sudo yum-builddep ovirt-engine-metrics-1.4.1.1-1.el8.src.rpm 
rpmbuild --rebuild ovirt-engine-metrics-1.4.1.1-1.el8.src.rpm 
sudo dnf install ../RPMS/noarch/ovirt-engine-metrics-1.4.1.1-1.fc32.noarch.rpm

# rpmbuild --rebuild ovirt-engine-ui-extensions-1.2.2-1.el8.src.rpm 
# sudo dnf install ../RPMS/noarch/ovirt-engine-ui-extensions-1.2.2-1.fc32.noarch.rpm
# missing ovirt-engine-webadmin-portal

# sudo yum-builddep ovirt-engine-api-explorer-0.0.6-1.el8.src.rpm
# missing ovirt-engine-yarn

# sudo yum-builddep ovirt-engine-dwh-4.4.1.2-1.el8.src.rpm
# sudo dnf install dom4j
# rpmbuild --rebuild ovirt-engine-dwh-4.4.1.2-1.el8.src.rpm 
# sudo dnf install ../RPMS/noarch/ovirt-engine-dwh-*
# missing ovirt-engine-setup-plugin-ovirt-engine-common 
#         python3-ovirt-setup-lib 
#         python2-ovirt-setup-lib


# 'vdsm-client
# 'vdsm-jsonrpc
# 'vdsm-python
sudo yum-builddep vdsm-4.40.22-1.el8.src.rpm 
rpmbuild --rebuild vdsm-4.40.22-1.el8.src.rpm
sed 's/\#rhel//g' -i ../SPECS/vdsm.spec
sed 's/\#\ fedora//' -i ../SPECS/vdsm.spec
sed 's/\#centos//' -i ../SPECS/vdsm.spec
sed 's/\#\ target\_py//' -i ../SPECS/vdsm.spec
sed 's/\#\ RHEL\ 8//' -i ../SPECS/vdsm.spec
sed 's/\#\ rhel//' -i ../SPECS/vdsm.spec

sudo yum-builddep cockpit-ovirt-0.14.10-1.el8.src.rpm 
sudo dnf install nodejs-packaging
rpmbuild --rebuild cockpit-ovirt-0.14.10-1.el8.src.rpm 
sudo dnf install ../RPMS/noarch/cockpit-ovirt-dashboard-0.14.10-1.fc32.noarch.rpm
