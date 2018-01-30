# KituraKit -  A Kitura v2 Client Library

[![Build Status](https://travis-ci.org/IBM-Swift/KituraKit.svg?branch=master)](https://travis-ci.org/IBM-Swift/KituraKit)
![macOS](https://img.shields.io/badge/os-macOS-green.svg?style=flat)
![Linux](https://img.shields.io/badge/os-linux-green.svg?style=flat)


[Kitura](http://kitura.io) is a lightweight web framework for creating complex web routes for web applications.

KituraKit allows developers to use the Swift 4 Codable protocol in their front and back end applications and use the same code on the front and backend.

## Usage

### Cocoapod Installation

#### Using an existing Podfile

1. Open your Podfile with your preferred text editor

2. Find the list of your currently installed pods and add to that list the following:
```
pod 'KituraKit', :git => 'https://github.com/IBM-Swift/KituraKit.git', :branch => 'pod'
```
3. Run `pod install` to install KituraKit.

#### Creating a new Podfile

1. Navigate to the root of your project (where your .xcodeproj directory is)

2. Run `pod init`  This will create a Podfile in your current directory.

3. Open the Podfile with your preferred text editer and under the "# Pods for 'your_project_name'>" line add:
```
pod 'KituraKit', :git => 'https://github.com/IBM-Swift/KituraKit.git', :branch => 'pod'
```
4. Install KituraKit by running the command: `pod install`

5. As well as installing KituraKit the `pod install` also creates an Xcode workspace which contains all of your installed pods. So you'll need to open the .xcworkspace (not .xcodeproj) to have access to those pods. This is the default behaviour of [Cocoapods](https://guides.cocoapods.org/using/getting-started.html).

### Examples

To run through a FoodTracker tutorial which covers various components of Kitura, including KituraKit, [click here](https://github.com/IBM/FoodTrackerBackend)

To try out the sample iOS project for yourself, making use of KituraKit, [click here](https://github.com/IBM-Swift/iOSSampleKituraKit).

## Swift version
The 0.0.x releases were tested on macOS and Linux using the Swift 4.0.3 binary. Please note that this is the default version of Swift that is include in [Xcode 9.2](https://developer.apple.com/xcode/).

## Community

We love to talk server-side Swift and Kitura. Join our [Slack](http://swift-at-ibm-slack.mybluemix.net/) to meet the team!
