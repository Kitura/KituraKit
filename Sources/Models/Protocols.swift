/**
 * Copyright IBM Corporation 2017
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

// NOTE: The contents of this file will more than likely be extracted to its own repository.
// This way we can share these protocols between the server (Kitura) and the client.

import Foundation

public protocol Identifier {
   init(value: String) throws
}

public struct IntId: Identifier {
    public let id: Int
    public init(value: String) throws {
        if let id = Int(value) {
            self.id = id
        } else {
            throw TypeError.unidentifiable
        }
    }
}

public enum TypeError: Error {
    case unidentifiable
    case unknown
}

public protocol Persistable {
    associatedtype Model: Codable = Self
    //associatedtype I: Identifiable
    // Create
    static func create(model: Model, respondWith: @escaping (Model, Error?) -> Void)
    // Read
    static func read(id: String, respondWith: @escaping (Model, Error?) -> Void)
    // Read all
    static func read(respondWith: @escaping ([Model], Error?) -> Void)
    // Update
    static func update(id: String, model: Model, respondWith: @escaping (Model, Error?) -> Void)
    // Delete
    static func delete(id: String, respondWith: @escaping (Error?) -> Void)
    // Delete all
    static func delete(respondWith: @escaping (Error?) -> Void)
}
