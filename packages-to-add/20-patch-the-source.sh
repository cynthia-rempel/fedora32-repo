# Placeholder to acknowledge the patching step

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


