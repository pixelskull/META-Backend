#! /bin/bash

# check root privileges
if [ "$(whoami)" != "root" ]; then
	echo "Sorry, root privileges are required..."
	exit 1
fi

THE_USER=${SUDO_USER:-${USERNAME:-unknown}}

# create folder for software use
echo ""
echo "################################################################"
echo "creating folder structure: ~/.META/"
sudo -u ${THE_USER} mkdir ~/.META/
echo "creating folder structure: ~/.META/template/"
sudo -u ${THE_USER} mkdir ~/.META/template/
echo "creating folder structure: ~/.META/services/"
sudo -u ${THE_USER} mkdir ~/.META/services/
sleep .5

# copying template to template folder
echo ""
echo "################################################################"
echo "copying ComputeUnitHandler template to ~/.META/template/"
sudo -u ${THE_USER} mkdir ~/.META/template/ComputeUnitHandler
sudo -u ${THE_USER} cp -R ./ComputeUnitHandler/ ~/.META/template/ComputeUnitHandler/

# copy frameworks to /Library/frameworks
echo ""
echo "################################################################"
echo "copying frameworks to /Library/Frameworks..."
cp -R -f ./Misc/Frameworks/* /Library/Frameworks
sleep .5
