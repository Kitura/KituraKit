//
//  main.swift
//  TypeSafeKituraClient
//
//  Created by Shihab Mehboob on 03/10/2017.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation
import TypeSafeKituraClient

let client = Client(baseURL: "http://localhost:8080")

extension Persistable {
    
    // setup name space based on name of model (eg. User -> user(s))
    let typeWithType: String = String(describing: type(of: self))
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

// Test out the functions with example struct
// To be moved to test class, and used in the iOS app
/*
struct Employee: Codable {
    let id: String
    let name: String
}

extension Employee: Persistable {
    typealias I = String
}

let Emp1 = Employee(id: "id", name: "name")
let Emp2 = try Employee.create(model: Emp1)
print(Emp1)
print(Emp2)
*/
