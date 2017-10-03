//
//  main.swift
//  TypeSafeKituraClient
//
//  Created by Shihab Mehboob on 03/10/2017.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

protocol Persistable {
    associatedtype Model: Codable
    associatedtype I: Codable
    // create
    static func create(model: Model) throws -> Model
    // read
    static func read(id: I) throws -> [Model]
    // read all
    static func read() throws -> [Model]
    // update
    static func update(id: I, model: Model) throws -> Model
    // delete
    static func delete(id: I) throws -> Void
    // delete all
    static func delete() throws -> Void
}

extension Persistable {
    
    // create
    static func create(model: Model) throws -> Model {
        // Perform post REST call...
        return model
    }
    // read
    static func read(id: I) throws -> [Model] {
        // Perform get REST call...
        let model: [Model] = []
        return model
    }
    // read all
    static func read() throws -> [Model] {
        // Perform get REST call...
        
        let model: [Model] = []
        return model
    }
    // update
    static func update(id: I, model: Model) throws -> Model {
        // Perform put REST call...
        return model
    }
    // delete
    static func delete(id: I) throws -> Void {
        // Perform delete REST call...
    }
    // delete all
    static func delete() throws -> Void {
        // Perform delete REST call...
    }
}

// Test out the functions with example struct

struct Employee: Codable {
    let id: String
    let name: String
}

extension Employee: Persistable {
    typealias Model = Employee
    typealias I = String
}

let Emp1 = Employee(id: "id", name: "name")
let Emp2 = try Employee.create(model: Emp1)
print(Emp1)
print(Emp2)
