

<p align="center">
    <a href="http://kitura.io/">
        <img src="https://raw.githubusercontent.com/IBM-Swift/Kitura/master/Sources/Kitura/resources/kitura-bird.svg?sanitize=true" height="100" alt="Kitura">
    </a>
</p>


<p align="center">
    <a href="http://www.kitura.io/">
    <img src="https://img.shields.io/badge/docs-kitura.io-1FBCE4.svg" alt="Docs">
    </a>
    <a href="https://travis-ci.org/IBM-Swift/KituraKit">
    <img src="https://travis-ci.org/IBM-Swift/KituraKit.svg?branch=master" alt="Build Status - Master">
    </a>
    <img src="https://img.shields.io/badge/os-macOS-green.svg?style=flat" alt="macOS">
    <img src="https://img.shields.io/badge/os-linux-green.svg?style=flat" alt="Linux">
    <img src="https://img.shields.io/badge/license-Apache2-blue.svg?style=flat" alt="Apache 2">
    <a href="http://swift-at-ibm-slack.mybluemix.net/">
    <img src="http://swift-at-ibm-slack.mybluemix.net/badge.svg" alt="Slack Status">
    </a>
</p>


# KituraKit -  A Kitura v2 Client Library

[Kitura](http://kitura.io) is a lightweight web framework for creating complex web routes for web applications.

KituraKit allows developers to use the Swift 4 Codable protocol in their front and back end applications and use the same code on the front and backend.

## Usage

### Cocoapod Installation

1. Navigate to the root of your project (where your .xcodeproj directory is)

2. If you don't already have a podfile, run `pod init`  to create a new podfile in your current directory.

3. Open the Podfile with your preferred text editer and under the "# Pods for 'your_project_name'>" line add:
```
pod 'KituraKit'
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
