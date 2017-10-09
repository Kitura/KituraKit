/*
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
 * See the License for the specific langua›ge governing permissions and
 * limitations under the License.
 */

import Foundation
import Models

//let client = Client(baseURL: "http://localhost:8080")

// TBD
protocol Persistable: Models.Persistable {
    // TBD
    static var client: Client { get }
    // TBD
}

extension Persistable {

    // Set up name space based on name of model (e.g. User -> user(s))
    static var modelType: String {
        let kind = String(describing: Swift.type(of: self))
        return String(kind.characters.dropLast(5))
    }
	static var routeSingular: String { return "/\(modelType.lowercased())" }
    static var routePlural: String { return "\(routeSingular)s" }

    // create
    static func create(model: Model, respondWith: @escaping (Model?) -> Void) {
        client.post(routePlural, data: model) { (model: Model?) -> Void in
           respondWith(model)
        }
    }

    // read
    static func read(id: String, respondWith: @escaping (Model?) -> Void) {
        client.get(routePlural, identifier: id) { (model: Model?) -> Void in
            respondWith(model)
        }
    }
    
    // read all
    static func read(respondWith: @escaping ([Model]?) -> Void) {
        client.get(routePlural) { (model: [Model]?) -> Void in
            respondWith(model)
        }
    }

    // update
    static func update(id: String, model: Model, respondWith: @escaping (Model?) -> Void) {
        client.put(routePlural, identifier: id, data: model) { (model: Model?) -> Void in
            respondWith(model)
        }
    }

    // delete
    static func delete(id: String, respondWith: @escaping () -> Void) {
        // Perform delete REST call...
        client.delete(routePlural, identifier: id) { (error: Error?) -> Void in
            //respondWith(error)
        }
    }

    // delete all
    static func delete(respondWith: @escaping () -> Void) {
        // Perform delete REST call...
        client.delete("/") { (error: Error?) -> Void in
            //respondWith(error)
        }
    }

}

