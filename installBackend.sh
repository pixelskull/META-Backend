#! /bin/bash

# check root privileges
if [ "$(whoami)" != "root" ]; then
	echo "Sorry, root privileges are required..."
	exit 1
fi

# copy frameworks to /Library/frameworks
echo ""
echo "################################################################"
echo "copying frameworks to /Library/Frameworks..."
cp -R ./Misc/Frameworks/ /Library/Frameworks
sleep .5

# create folder for software use
echo ""
echo "################################################################"
echo "creating folder structure: ~/.META/"
mkdir ~/.META/
echo "creating folder structure: ~/.META/template/"
mkdir ~/.META/template/
echo "creating folder structure: ~/.META/services/"
mkdir ~/.META/services/
sleep .5

# copying template to template folder
echo ""
echo "################################################################"
echo "copying ComputeUnitHandler template to ~/.META/template/"
mkdir ~/.META/template/ComputeUnitHandler
cp -R ./ComputeUnitHandler/ ~/.META/template/ComputeUnitHandler/
