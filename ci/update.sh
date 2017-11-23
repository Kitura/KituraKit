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

# Actions after Swift installation

git remote rm origin
git remote add origin https://SwiftDevOps:${GH_TOKEN}@github.com/IBM-Swift/KituraKit
git fetch
git checkout pod
git pull origin master 

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

cd ../../../

rm -rf Package-Builder/
git add -A
NEW_VERSION='cat ci/VERSION'
git commit -m "Updating pod branch to version: $NEW_VERSION"
git push origin pod
