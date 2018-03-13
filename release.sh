#!/bin/bash
# Cuts new releases

cd "$( dirname "${BASH_SOURCE[0]}")"

currentCodeVersion=$(python setup.py --version)
currentGitTag=$(git tag | tail -n 1 )

if [[ ! $(git diff-index --quiet HEAD --) ]]
then
    echo "There are uncommitted changes to the repo. Please commit or stash changes before releasing."
    #exit 1
fi

read -p "Release will be cut and git tag created based on what is currently committed. Proceed? [y/N]: " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Aborting. Commit all files to git before running release.shS"
    exit 1
fi

echo "Current Git Tag: " $currentGitTag
echo "Current Code version: " $currentCodeVersion

#
# Ask for new version.
#

read -p "Please specify new version: " newVersion

#
# change version in code.
#

sed -i "s/__version__ = \"${currentCodeVersion}\"/__version__ = \"${newVersion}\"/" dnskeeper/dnskeeper.py

#
# Create git tag for specified version.
#

git add *

git commit -m "Cuts release ${newVersion}"

git tag -a "${newVersion}"

git push origin master --tags

#
# Create distribution files.
#

python setup.py bdist_wheel
python setup.py sdist

#
# Push to PyPi
#

read -p "Push build to PyPi? [y/N]: " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Aborting. Manually push with twine upload ./dist/*"
    exit 1
fi

twine upload ./dist/*
rm ./dist/*