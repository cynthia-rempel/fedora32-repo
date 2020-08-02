# Placeholder to acknowledge the patching step

# identify which packages need to be installed for a build to succeed
sudo yum-builddep ./*.rpm > log.txt 2>&1
grep matching log.txt | sort | uniq | awk '{print $6}'
