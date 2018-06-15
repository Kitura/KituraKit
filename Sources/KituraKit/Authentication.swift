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

import Foundation
import LoggerAPI
import SwiftyRequest
import KituraContracts

extension KituraKit {
    
    /// Add a username and password that will be used for HTTP basic authentication in the requests
    /// - Parameter username: The unique user id that identifies the user
    /// - Parameter password: The password for the given username
    public func addBasicAuth(username: String, password: String) {
        basicAuthentication = .basicAuthentication(username: username, password: password)
    }
    
    /// Add a Facebook oauth token that will be used as authentication in the requests
    /// - Parameter token: The Facebook oauth token
    public func addFacebookToken(_ token: String) {
        headers["X-token-type"] = "FacebookToken"
        headers["access_token"] = token
    }
    
    /// Add a Google oauth token that will be used as authentication in the requests
    /// - Parameter token: The Google oauth token
    public func addGoogleToken(_ token: String) {
        headers["X-token-type"] = "GoogleToken"
        headers["access_token"] = token
    }
}
