

<p align="center">
    <a href="http://kitura.io/">
        <img src="https://raw.githubusercontent.com/IBM-Swift/Kitura/master/Sources/Kitura/resources/kitura-bird.svg?sanitize=true" height="100" alt="Kitura">
    </a>
</p>


<p align="center">
    <a href="https://ibm-swift.github.io/KituraKit/index.html">
    <img src="https://img.shields.io/badge/apidoc-KituraKit-1FBCE4.svg?style=flat" alt="APIDoc">
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

#### Using an existing Podfile

1. Open your Podfile with your preferred text editor.

2. Find the list of your currently installed pods and add to that list:
```
pod 'KituraKit', :git => 'https://github.com/IBM-Swift/KituraKit.git', :branch => 'pod'
```
3. Run `pod install` to install KituraKit.

#### Creating a new Podfile

1. Navigate to the root of your project (the directory containing your `.xcodeproj` file).

2. Run `pod init`.  This will create a Podfile in your current directory.

3. Open the Podfile with your preferred text editer and under the "# Pods for 'your_project_name'>" line add:
```
pod 'KituraKit', :git => 'https://github.com/IBM-Swift/KituraKit.git', :branch => 'pod'
```
4. Install KituraKit by running the command: `pod install`.

5. As well as installing KituraKit the `pod install` also creates an Xcode workspace which contains all of your installed pods. So you'll need to open the `.xcworkspace` file (not `.xcodeproj`) to have access to those pods. This is the default behaviour of [Cocoapods](https://guides.cocoapods.org/using/getting-started.html).

### SPM Installation

We expect users on the client side to use the Cocoapod installation, however, if you require access to KituraKit from the server you can use Swift Package Manager.

#### Add dependencies

Add the `KituraKit` package to the dependencies within your application’s `Package.swift` file. Substitute `"x.x.x"` with the latest `KituraKit` [release](https://github.com/IBM-Swift/KituraKit/releases).

```swift
.package(url: "https://github.com/IBM-Swift/KituraKit.git", from: "x.x.x")
```

Add `KituraKit` to your target's dependencies:

```swift
.target(name: "example", dependencies: ["KituraKit"]),
```

#### Import package

  ```swift
  import KituraKit
  ```

## Examples

To run through a FoodTracker tutorial which covers various components of Kitura, including KituraKit, [click here](https://github.com/IBM/FoodTrackerBackend).

To try out a sample iOS project yourself, which makes use of KituraKit, [click here](https://github.com/IBM-Swift/iOSSampleKituraKit).

## API Documentation
For more information visit our [API reference](https://ibm-swift.github.io/KituraKit/index.html).

## Community

We love to talk server-side Swift, and Kitura. Join our [Slack](http://swift-at-ibm-slack.mybluemix.net/) to meet the team!

## License
This library is licensed under Apache 2.0. Full license text is available in [LICENSE](https://github.com/IBM-Swift/KituraKit/blob/master/LICENSE).
