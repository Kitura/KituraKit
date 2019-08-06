

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

[Kitura](http://kitura.io) is a lightweight web framework for writing Swift server applications.

KituraKit is a client side framework for sending HTTP requests to a Kitura server. By using the Swift `Codable` protocol, you can send and receive models directly from client to server.

## Swift version
The latest version of KituraKit requires **Swift 4.0** or later. You can download this version of the Swift binaries by following this [link](https://swift.org/download/).

## Usage

### Cocoapod Installation

1. Navigate to the root of your project (where your .xcodeproj directory is)

2. If you don't already have a podfile, run `pod init`  to create a new podfile in your current directory.

3. Open the Podfile with your preferred text editor and under the "# Pods for 'your_project_name'>" line add:
```
pod 'KituraKit'
```
4. Install KituraKit by running the command: `pod install`

5. As well as installing KituraKit, the `pod install` also creates an Xcode workspace which contains all of your installed pods. So you'll need to open the `.xcworkspace` file (not `.xcodeproj`) to have access to those pods. This is the default behaviour of [Cocoapods](https://guides.cocoapods.org/using/getting-started.html).

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

### Examples

To run through a FoodTracker tutorial which covers various components of Kitura, including KituraKit, [click here](https://github.com/IBM/FoodTrackerBackend)

To try out the sample iOS project for yourself, making use of KituraKit, [click here](https://github.com/IBM-Swift/iOSSampleKituraKit).

## API Documentation

### KituraKit

The `KituraKit` class handles the connection to your Kitura server and executes the REST requests.

You create a `KituraKit` instance by providing the URL of your Kitura server:
```swift
if let client = KituraKit(baseURL: "http://localhost:8080") {
    // Use client to make requests here
}
```

#### Codable Models

Kitura and KituraKit send and receive instances of Swift types directly. These types (aka models) can be shared between the client and server.

The only requirement for a model is that it conforms to the `Codable` protocol:

```swift
public struct User: Codable {
    public let name: String
    public init(name: String) {
        self.name = name
    }
}
```

#### HTTP Requests

The signatures for HTTP requests in KituraKit mirror the Codable routes in Kitura. We will demonstrate what the code for this looks like in the following examples.

If you had the following GET route on your server:
```swift
// Kitura server route
router.get("/users") { (completion: ([User]?, RequestError?) -> Void) in
    let users = [User(name: "Joe"), User(name: "Bloggs")]
    completion(users, nil)
}
```
You would make a request to it using the `get` function on your `KituraKit` client:
```swift
// KituraKit client request
client.get("/users") { (users: [User]?, error: RequestError?) -> Void in
    if let users = users {
        // GET successful, work with returned users here
    }
}
```

Similarly, to make a request to a Kitura POST route:
```swift
// Kitura server route
router.post("/users") { (user: User, completion: (User?, RequestError?) -> Void) in
    completion(user, nil)
}
```
You would make a request to it using the `post` function on your `KituraKit` client:
```swift
// KituraKit client request
let newUser = User(name: "Kitura")
client.post("/users", data: newUser) { (user: User?, error: RequestError?) -> Void in
    if let user = user {
        // POST successful, work with returned users here
    }
}
```

KituraKit supports the following REST requests:
- GET a Codable object.
- GET a Codable object using an identifier.
- GET a Codable object using query parameters.
- POST a Codable object.
- POST a Codable object and be returned an identifier.
- PUT a Codable object using an identifier.
- PATCH a Codable object using an identifier.
- DELETE using an identifier.
- DELETE without an identifier.

### Authentication

The Kitura server can authenticate users using the [Credentials](https://github.com/IBM-Swift/Kitura-Credentials) repository. KituraKit allows you to provide credentials alongside your request to identify yourself to the server.

**Note:** When sending credentials you should always use HTTPS to avoid sending passwords/tokens as plaintext.

You can set default credentials for your client which will be attached to all requests. If your server is using [Kitura-CredentialsHTTP](https://github.com/IBM-Swift/Kitura-CredentialsHTTP) for basic authentication, you would provide the username and password as follows:
```swift
if let client = KituraKit(baseURL: "https://localhost:8080") {
    client.defaultCredentials = HTTPBasic(username: "John", password: "12345")
}
```

Alternatively, you can provide the credentials directly on the request:
```swift
let credentials = HTTPBasic(username: "Mary", password: "abcde")
client.get("/protected", credentials: credentials) { (users: [User]?, error: RequestError?) -> Void in
    if let users = users {
        // work with users
    }
}
```

KituraKit supports client side authentication for the following plugins:

- HTTP Basic using [Kitura-CredentialsHTTP](https://github.com/IBM-Swift/Kitura-CredentialsHTTP).
- Facebook OAuth token using [Kitura-CredentialsFacebook](https://github.com/IBM-Swift/Kitura-CredentialsFacebook)
- Google OAuth token using [Kitura-CredentialsGoogle](https://github.com/IBM-Swift/Kitura-CredentialsGoogle)
- JWT token (Kitura-CredentialsJWT coming soon)

For more information visit our [API reference](https://ibm-swift.github.io/KituraKit/index.html).

## Community

We love to talk server-side Swift and Kitura. Join our [Slack](http://swift-at-ibm-slack.mybluemix.net/) to meet the team!

## License
This library is licensed under Apache 2.0. Full license text is available in [LICENSE](https://github.com/IBM-Swift/KituraKit/blob/master/LICENSE).
