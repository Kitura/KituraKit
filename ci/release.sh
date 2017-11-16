git remote rm origin
git remote add origin https://SwiftDevOps:${GH_TOKEN}@github.com/IBM-Swift/KituraKit
git fetch
git checkout tempMaster
cd ci
if [ -f VERSION ]; then
    BASE_VERSION_STRING=`cat VERSION`
    BASE_VERSION_LIST=(`echo $BASE_VERSION_STRING | tr '.' ' '`)
    V_MAJOR=${BASE_VERSION_LIST[0]}
    V_MINOR=${BASE_VERSION_LIST[1]}
    V_PATCH=${BASE_VERSION_LIST[2]}

    V_PATCH=$((V_PATCH + 1))
    NEW_VERSION="$V_MAJOR.$V_MINOR.$V_PATCH"

    echo $NEW_VERSION > VERSION
    git add VERSION
    git commit -m "New release of KituraKit at $NEW_VERSION"
    git push origin tempMaster 
    git tag -a -m "Tagging version $NEW_VERSION" "v$NEW_VERSION"
    git push origin $NEW_VERSION
fi
