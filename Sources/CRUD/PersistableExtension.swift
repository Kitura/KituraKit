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
import TypeSafeKituraClient
import Models

let client = Client(baseURL: "http://localhost:8080")

extension Persistable {

    // setup name space based on name of model (eg. User -> user(s))
    let typeWithType: String = String(describing: type(of: Self))
    let typeName = String(typeWithType.characters.dropLast(5))
    let single = "/\(typeName.lowercased())"
    let plural = "\(single)s"

    // create
    static func create(model: Model, respondWith: @escaping (Model) -> Void) {
        // Perform post REST call...
        client.post("/\(plural)", data: model) { (model: Model?) -> Void in
            guard let model = model else {
                return
            }
            return model
        }
    }

    // read
    static func read(id: I, respondWith: @escaping (Model) -> Void) {
        // Perform get REST call...
        client.get("/\(plural)", identifier: id) { (model: Model?) -> Void in
            guard let model = model else {
                return
            }
            return model
        }
    }

    // read all
    static func read(respondWith: @escaping (Model) -> Void) {
        // Perform get REST call...
        client.get("/\(plural)") { (model: [Model]?) -> Void in
            guard let model = model else {
                return
            }
            return model
        }
    }

    // update
    static func update(id: I, model: Model, respondWith: @escaping (Model) -> Void) {
        // Perform put REST call...
        client.put("/\(plural)", identifier: id, data: model) { (model: Model?) -> Void in
            guard let model = model else {
                return
            }
            return model
        }
    }

    // delete
    static func delete(id: I, respondWith: @escaping () -> Void) {
        // Perform delete REST call...
        client.delete("/\(plural)", identifier: id) { () -> Void in

        }
    }

    // delete all
    static func delete(respondWith: @escaping () -> Void) {
        // Perform delete REST call...
        client.delete("/\(plural)") { () -> Void in

        }
    }

}

