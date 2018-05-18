#!/bin/bash
##
# Copyright IBM Corporation 2017
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
##

# Store the absolute path of the project root directory in a variable.
projectDir=$(pwd)

osName="linux"
if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then osName="osx"; fi
export osName
export projectFolder=`pwd`
projectName="$(basename $projectFolder)"
export SWIFT_SNAPSHOT=swift-4.0
sudo apt-get -qq update > /dev/null
sudo apt-get -y -qq install clang lldb-3.8 libicu-dev libtool libcurl4-openssl-dev libbsd-dev build-essential libssl-dev uuid-dev tzdata libz-dev > /dev/null

# Environment vars
version=`lsb_release -d | awk '{print tolower($2) $3}'`
export UBUNTU_VERSION=`echo $version | awk -F. '{print $1"."$2}'`
export UBUNTU_VERSION_NO_DOTS=`echo $version | awk -F. '{print $1$2}'`

if [[ ${SWIFT_SNAPSHOT} =~ ^.*RELEASE.*$ ]]; then
        SNAPSHOT_TYPE=$(echo "$SWIFT_SNAPSHOT" | tr '[:upper:]' '[:lower:]')
elif [[ ${SWIFT_SNAPSHOT} =~ ^swift-.*-DEVELOPMENT.*$ ]]; then
  SNAPSHOT_TYPE=${SWIFT_SNAPSHOT%-DEVELOPMENT*}-branch
elif [[ ${SWIFT_SNAPSHOT} =~ ^.*DEVELOPMENT.*$ ]]; then
        SNAPSHOT_TYPE=development
else
        SNAPSHOT_TYPE="$(echo "$SWIFT_SNAPSHOT" | tr '[:upper:]' '[:lower:]')-release"
  SWIFT_SNAPSHOT="${SWIFT_SNAPSHOT}-RELEASE"
fi

echo ">> Installing '${SWIFT_SNAPSHOT}'..."
# Install Swift compiler
cd $projectFolder
wget https://swift.org/builds/$SNAPSHOT_TYPE/$UBUNTU_VERSION_NO_DOTS/$SWIFT_SNAPSHOT/$SWIFT_SNAPSHOT-$UBUNTU_VERSION.tar.gz
tar xzf $SWIFT_SNAPSHOT-$UBUNTU_VERSION.tar.gz
export PATH=$projectFolder/$SWIFT_SNAPSHOT-$UBUNTU_VERSION/usr/bin:$PATH
rm $SWIFT_SNAPSHOT-$UBUNTU_VERSION.tar.gz

# Actions after Swift installation

git remote rm origin
git remote add origin https://SwiftDevOps:${GITHUB_TOKEN}@github.com/IBM-Swift/KituraKit
git fetch
git checkout pod
git pull origin master 

swift package resolve

cd .build/checkouts/LoggerAPI*
rm -rf $projectDir/Sources/KituraKit/LoggerAPI
cp -r Sources/LoggerAPI $projectDir/Sources/KituraKit

cd ../CircuitBreaker*
rm -rf $projectDir/Sources/KituraKit/CircuitBreaker
cp -r Sources/CircuitBreaker $projectDir/Sources/KituraKit

cd ../KituraContracts*
rm -rf $projectDir/Sources/KituraKit/KituraContracts
cp -r  Sources/KituraContracts $projectDir/Sources/KituraKit
mv $projectDir/Sources/KituraKit/KituraContracts/CodableQuery/*.swift $projectDir/Sources/KituraKit/KituraContracts/

cd ../SwiftyRequest*
rm -rf $projectDir/Sources/KituraKit/SwiftyRequest
cp -r Sources/SwiftyRequest $projectDir/Sources/KituraKit


# Remove all the import statements that aren't needed 
read -a SWIFTFILES <<< $(find $projectDir/Sources -name "*.swift")
for file in "${SWIFTFILES[@]}"
do
	tempfile=$(mktemp)
	python ../../ci/filter_imports.py $file > $tempfile
	mv $tempfile $file
	chmod a+r $file
done

cd $DIR

rm -rf swift-4.0-RELEASE-ubuntu14.04/
rm -rf Package-Builder/
git add -A
NEW_VERSION='cat ci/VERSION'
git commit -m "Updating pod branch to version: $NEW_VERSION"
git push origin pod
