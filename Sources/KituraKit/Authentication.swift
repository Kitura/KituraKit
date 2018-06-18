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

/// Generate headers for a authenticating with a username and password using HTTP basic
/// - Parameter username: The unique user id that identifies the user
/// - Parameter password: The password for the given username
public struct HTTPBasicAuth: ClientAuth {
    let username: String
    let password: String
    
    public func getHeaders() -> [String : String] {
        let authData = (username + ":" + password).data(using: .utf8)!
        let authString = authData.base64EncodedString()
        return ["Authorization": "Basic \(authString)"]
    }
}

/// Generate headers for a authenticating with a Facebook oauth token
/// - Parameter token: The Facebook oauth token
public struct FacebookTokenAuth: ClientAuth {
    let token: String
    
    public func getHeaders() -> [String : String] {
        return ["X-token-type": "FacebookToken", "access_token": self.token]
    }
}

/// Generate headers for a authenticating with a Google oauth token
/// - Parameter token: The Google oauth token
public struct GoogleTokenAuth: ClientAuth {
    let token: String
    
    public func getHeaders() -> [String : String] {
        return ["X-token-type": "GoogleToken", "access_token": self.token]
    }
}

public protocol ClientAuth {
    func getHeaders() -> [String: String]
}


