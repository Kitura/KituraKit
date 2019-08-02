/**
 * Copyright IBM Corporation 2018
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import Foundation

/**
 A protocol that credentials must implement to be used in KituraKit routes.
 
 Classes or structs that conform to `ClientCredentials` must contain a `getHeaders()` function
 that will return the HTTP headers required to authenticate using the provided credentials.
 ### Usage Example: ###
 ```swift
 public struct MyToken: ClientCredentials {
    public let token: String
 
    public func getHeaders() -> [String : String] {
        return ["X-token-type": "MyToken", "access_token": self.token]
    }
 }
 
 client.get("/protected", credentials: MyToken(token: "12345")) { (user: User?, error: RequestError?) -> Void in
     guard let user = user else {
        print("failed request")
     }
     print(user)
 }
 ```
 */
public protocol ClientCredentials {
    
    /// Function to generate headers that will be added to the
    /// client request using the provided credentials.
    func getHeaders() -> [String: String]
}

/**
 A struct for providing HTTP basic credentials to a KituraKit route.
 The struct is initialized with a username and password, which will be used to authenticate the user.
 This client route mirrors a Kitura Codable route that implements [TypeSafeHTTPBasic](https://ibm-swift.github.io/Kitura-CredentialsHTTP/Protocols/TypeSafeHTTPBasic.html) authentication to verify a users identity.
 ### Usage Example: ###
 ```swift
 struct User: Codable {
    let name: String
 }
 
 client.get("/protected", credentials: HTTPBasic(username: "John", password: "12345")) { (user: User?, error: RequestError?) -> Void in
    guard let user = user else {
        print("failed request: \(error)")
    }
    print("Successfully authenticated and recieved \(user)")
 }
 ```
 */
public struct HTTPBasic: ClientCredentials {
    /// The user id that uniquely identifies the user
    public let username: String
    
    /// The password for the given username
    public let password: String

    /// Create an HTTP Basic credentials instance with the specified username and password.
    public init(username: String, password: String) {
        self.username = username
        self.password = password
    }

    /// Function to generate headers using a username and password for HTTP basic authentication.
    /// The "Authorization" header is set to be the string "Basic" followed by username:password
    /// encoded as a base64 encoded string.
    public func getHeaders() -> [String : String] {
        let authData = (username + ":" + password).data(using: .utf8)!
        let authString = authData.base64EncodedString()
        return ["Authorization": "Basic \(authString)"]
    }
}

/**
 A struct for providing a Facebook Oauth token as credentials to a KituraKit route.
 The struct is initialized with a token, which will be used to authenticate the user and generate their user profile.
 This client route mirrors a Kitura Codable route that implements [TypeSafeFacebookToken](https://ibm-swift.github.io/Kitura-CredentialsFacebook/Protocols/TypeSafeFacebookToken.html) authentication to verify a users identity.
 ### Usage Example: ###
 ```swift
 struct User: ExampleProfile {
    let id: String
    let name: String
    let email: String?
 }
 
 client.get("/facebookProfile", credentials: FacebookToken(token: "exampleToken")) { (user: ExampleProfile?, error: RequestError?) -> Void in
    guard let user = user else {
        print("failed request: \(error)")
    }
    print("Successfully authenticated and recieved \(user)")
 }
 ```
 */
public struct FacebookToken: ClientCredentials {
    /// The users Facebook Oauth token
    public let token: String
    
    /// Create a Facebook Token credentials instance with the specified token data.
    public init(token: String) {
        self.token = token
    }

    /// Function to generate headers using a provided token Facebook token authentication.
    /// The "X-token-type" header is set to be "FacebookToken"
    /// and the "access_token" header is set as the provided token.
    public func getHeaders() -> [String : String] {
        return ["X-token-type": "FacebookToken", "access_token": self.token]
    }
}

/**
 A struct for providing a Google Oauth token as credentials to a KituraKit route.
 The struct is initialized with a token, which will be used to authenticate the user and generate their user profile.
 This client route mirrors a Kitura Codable route that implements [TypeSafeGoogleToken](https://ibm-swift.github.io/Kitura-CredentialsGoogle/Protocols/TypeSafeGoogleToken.html) authentication to verify a users identity.
 ### Usage Example: ###
 ```swift
 struct User: ExampleProfile {
    let id: String
    let name: String
    let email: String?
 }
 
 client.get("/googleProfile", credentials: GoogleToken(token: "exampleToken")) { (user: ExampleProfile?, error: RequestError?) -> Void in
    guard let user = user else {
        print("failed request: \(error)")
    }
    print("Successfully authenticated and recieved \(user)")
 }
 ```
 */
public struct GoogleToken: ClientCredentials {
    /// The users Google Oauth token
    public let token: String
    
    /// Create a Google Token credentials instance with the specified token data.
    public init(token: String) {
        self.token = token
    }

    /// Function to generate headers using a provided token Google token authentication.
    /// The "X-token-type" header is set to be "GoogleToken"
    /// and the "access_token" header is set as the provided token.
    public func getHeaders() -> [String : String] {
        return ["X-token-type": "GoogleToken", "access_token": self.token]
    }
}

/**
 A struct for providing a JWT as credentials to a KituraKit route.
 The struct is initialized with a token, which will be used to authenticate the user and generate their user profile.
 ### Usage Example: ###
 ```swift
 struct JWTUser: Codable {
    let name: String
 }
 
 client.get("/protected", credentials: JWTCredentials(token: "exampleToken")) { (user: JWTUser?, error: RequestError?) -> Void in
    guard let user = user else {
        print("failed request: \(error)")
    }
    print("Successfully authenticated and recieved \(user)")
 }
 ```
 */
public struct JWTCredentials: ClientCredentials {
    /// The users JWT
    public let token: String
    
    /// Create a JWT credentials instance with the specified token data.
    public init(token: String) {
        self.token = token
    }

    /// Function to generate headers using a provided token JWT authentication.
    /// The "X-token-type" header is set to be "JWT"
    /// and the "Authorization: Bearer " is the header for a JWT
    public func getHeaders() -> [String : String] {
        return ["X-token-type": "JWT", "Authorization": "Bearer \(self.token)"]
    }
}

/**
 A type used to indicate that no credentials should be passed for this request. This can
 be used to override the default credentials for a client, to prevent those credentials
 from being used for a particular request.
 ### Usage Example: ###
 ```swift
 client.get("/public", credentials: NilCredentials()) { (response: MyResponse?, error: RequestError?) -> Void in
     guard let response = response else {
         print("failed request: \(error)")
     }
     print("Successfully recieved \(response)")
 }
 ```
 */
public struct NilCredentials: ClientCredentials {

    /// Create an instance that represents no credentials.
    public init() {}

    /// Returns an empty dictionary.
    public func getHeaders() -> [String : String] {
        return [:]
    }
}

