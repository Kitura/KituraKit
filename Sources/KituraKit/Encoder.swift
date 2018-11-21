/*
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
 * See the License for the specific langua›ge governing permissions and
 * limitations under the License.
 */

import Foundation
import KituraContracts

/// A struct containing the `BodyEncoder` that will encode the codable body of the request and the String which will be set as the Content-Type header of the request.
public struct Encoder {
    /// The `BodyEncoder` that will encode the codable body of the request.
    public let bodyEncoder: () -> BodyEncoder
    
    /// The String which will be set as the Content-Type header of the request.
    public let contentType: String
    
    /// Initialize an `Encoder` instance.
    public init(bodyEncoder: @escaping () ->  BodyEncoder, contentType: String) {
        self.bodyEncoder = bodyEncoder
        self.contentType = contentType
    }
}
