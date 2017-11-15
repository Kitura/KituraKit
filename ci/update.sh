# Install swift for SPM

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
git remote add origin https://SwiftDevOps:${GH_TOKEN}@github.com/IBM-Swift/KituraKit
git fetch
git checkout pod
git pull origin tempMaster 

swift package resolve

cd .build/checkouts/LoggerAPI*
cp -r Sources/LoggerAPI ../../../Sources/KituraKit

cd ../CircuitBreaker*
cp -r Sources/CircuitBreaker ../../../Sources/KituraKit

cd ../KituraContracts*
cp -r  Sources/KituraContracts ../../../Sources/KituraKit

cd ../SwiftyRequest*
cp -r Sources/SwiftyRequest ../../../Sources/KituraKit

cd ../../../Sources/KituraKit

# Remove all the import statements that aren't needed 

sed -i '/import LoggerAPI/d' Client.swift
sed -i '/import KituraContracts/d' Client.swift
sed -i '/import SwiftyRequest/d' Client.swift
sed -i '/import KituraContracts/d' PersistableExtension.swift
sed -i '/import KituraContracts/d' RequestErrorExtension.swift
sed -i '/import SwiftyRequest/d' RequestErrorExtension.swift
cd SwiftyRequest/
sed -i '/import CircuitBreaker/d' RestRequest.swift
cd ../CircuitBreaker
sed -i '/import LoggerAPI/d' CircuitBreaker.swift
sed -i '/import LoggerAPI/d' Stats.swift

rm -rf ../../../swift-4.0-RELEASE-ubuntu14.04/

if [ -f VERSION ]; then
    BASE_VERSION_STRING=`cat VERSION`
    BASE_VERSION_LIST=(`echo $BASE_VERSION_STRING | tr '.' ' '`)
    V_MAJOR=${BASE_VERSION_LIST[0]}
    V_MINOR=${BASE_VERSION_LIST[1]}
    V_PATCH=${BASE_VERSION_LIST[2]}

    V_PATCH=$((V_PATCH + 1))
    NEW_VERSION="$V_MAJOR.$V_MINOR.$V_PATCH"
    echo $NEW_VERSION > VERSION
fi

git add -A
git commit -m "Updating pod branch to latest version"
git push origin pod

git checkout tempMaster

cd ../../../ci

git checkout pod VERSION

if [ -f VERSION ]; then
    NEW_VERSION=`cat VERSION`
    git tag -a -m "Tagging version $NEW_VERSION" "v$NEW_VERSION"
    git push origin v$NEW_VERSION
fi
