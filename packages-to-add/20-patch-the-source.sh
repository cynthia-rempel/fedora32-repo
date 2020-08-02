# Placeholder to acknowledge the patching step

# identify which packages need to be installed for a build to succeed
sudo yum-builddep ./*.rpm > log.txt 2>&1
grep matching log.txt | sort | uniq | awk '{print $6}'

# ovirt-engine-nodejs-modules
sed 's/Source0.*/Source0\:\ yarn-offline-cache.tar/' -i ../SPECS/ovirt-engine-nodejs-modules.spec
sed 's/\%..yarn./yarn-1.22.0.js/' -i ../SPECS/ovirt-engine-nodejs-modules.spec
