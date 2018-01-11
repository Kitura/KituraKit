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
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Kitura
import Foundation
import KituraContracts

public class Controller {

    public typealias Key = String

    public let router: Router

    private var userStore: [Key: User] = [:]
    private var employeeStore: [Key: Employee] = [:]

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    public init(userStore: [Key: User] = [:], employeeStore: [Key: Employee] = [:]) {
        self.userStore = userStore
        self.employeeStore = employeeStore
        router = Router()
        setupRoutes()
    }

    private func setupRoutes() {
        // users routes
        router.get("/users")  { (respondWith: ([User]?, RequestError?) -> Void) in
            let users = self.userStore.map({ $0.value })
            respondWith(users, nil)
        }

        router.get("/users") { (id: Int, respondWith: (User?, RequestError?) -> Void) in
            guard let user = self.userStore[id.value] else {
                respondWith(nil, .notFound)
                return
            }
            respondWith(user, nil)
        }

        router.post("/users") { (user: User?, respondWith: (User?, RequestError?) -> Void) in
            guard let user = user else {
                respondWith(nil, .badRequest)
                return
            }
            self.userStore[String(user.id)] = user
            respondWith(user, nil)
        }

        router.post("/usersid") { (user: User?, respondWith: (Int?, User?, RequestError?) -> Void) in
            guard let user = user else {
                respondWith(nil, nil, .badRequest)
                return
            }
            self.userStore[String(user.id)] = user
            respondWith(user.id, user, nil)
        }

        router.put("/users") { (id: Int, user: User?, respondWith: (User?, RequestError?) -> Void) in
            self.userStore[String(id)] = user
            respondWith(user, nil)
        }
        router.patch("/users") { (id: Int, user: UserOptional?, respondWith: (User?, RequestError?) -> Void) in
            guard let exisitingUser = self.userStore[id.value] else {
                respondWith(nil, .notFound)
                return
            }
            if let userName = user?.name {
                let updatedUser = User(id: id, name: userName)
                self.userStore[id.value] = updatedUser
                respondWith(updatedUser, nil)
            } else {
                respondWith(exisitingUser, nil)
            }
        }

        router.delete("/users") { (id: Int, respondWith: (RequestError?) -> Void) in
            guard let _ = self.userStore.removeValue(forKey: id.value) else {
                respondWith(.notFound)
                return
            }
            respondWith(nil)
        }

        router.delete("/users") { (respondWith: (RequestError?) -> Void) in
            self.userStore.removeAll()
            respondWith(nil)
        }
        // employees routes
        router.get("/employees", handler: getEmployees)
        router.get("/employees/:id", handler: getEmployee)
        router.post("/employees", handler: addEmployee)
        router.put("/employees/:id", handler: addEmployee)
        router.patch("/employees/:id", handler: updateEmployee)
        router.delete("/employees/:id", handler: deleteEmployee)
        router.delete("/employees", handler: deleteAllEmployees)
        // health route
        router.get("/health") { (respondWith: (Status?, RequestError?) -> Void) in
            respondWith(Status("GOOD"), nil)
        }
    }


    public func updateUser(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        defer {
            next()
        }
        guard let id = request.parameters["id"] else {
            response.status(.badRequest)
            return
        }
        do {
            var data = Data()
            _ = try request.read(into: &data)
            let user = try decoder.decode(User.self, from: data)
            userStore[id] = user
            response.status(.OK).send(data: data)
        } catch {
            response.status(.unprocessableEntity)
        }
    }

    public func getEmployees(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        let employees = employeeStore.map { $1 }
        try response.status(.OK).send(data: encoder.encode(employees)).end()
    }

    public func getEmployee(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        defer {
            next()
        }
        guard let id = request.parameters["id"] else {
            response.status(.badRequest)
            return
        }

        //print("employeeStore - \(employeeStore)")

        guard let employee = employeeStore[id] else {
            response.status(.badRequest)
            return
        }

        try response.status(.OK).send(data: encoder.encode(employee))
    }

    public func addEmployee(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        defer {
            next()
        }
        do {
            var data = Data()
            _ = try request.read(into: &data)
            let employee = try decoder.decode(Employee.self, from: data)

            let employees = employeeStore.map({ $0.value })

            for current in employees {
                if current == employee {
                    response.status(.conflict)
                    return
                }
            }
            employeeStore[String(employee.id)] = employee

            response.status(.OK).send(data: data)
        } catch {
            response.status(.unprocessableEntity)
        }
    }

    public func updateEmployee(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        defer {
            next()
        }
        guard let id = request.parameters["id"] else {
            response.status(.badRequest)
            return
        }
        do {
            var data = Data()
            _ = try request.read(into: &data)
            let employee = try decoder.decode(Employee.self, from: data)
            employeeStore[id] = employee
            response.status(.OK).send(data: data)
        } catch {
            response.status(.unprocessableEntity)
        }
    }

    public func deleteAllEmployees(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        employeeStore = [:]
        try response.status(.OK).end()
    }

    public func deleteEmployee(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        defer {
            next()
        }
        guard let id = request.parameters["id"] else {
            response.status(.badRequest)
            return
        }

        guard let _ = employeeStore[id] else {
            response.status(.notFound)
            return
        }
        employeeStore.removeValue(forKey: id)
        response.status(.OK)
    }
}


