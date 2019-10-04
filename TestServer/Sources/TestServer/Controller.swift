/*
 * Copyright IBM Corporation 2017-2019
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

import Foundation
import Kitura
//import KituraContracts
import SwiftJWT

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
        setupBasicAuthRoutes()
        setupFacebookAuthRoutes()
        setupGoogleAuthRoutes()
        setupJWTAuthRoutes()
    }

    private func setupRoutes() {
        // reset route
        router.get("/reset") { (respondWith: (Status?, RequestError?) -> Void) in
            self.userStore = initialStore
            respondWith(Status("success"), nil)
        }

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

        router.post("/invaliduser") { (user: User?, respondWith: (Int?, User?, RequestError?) -> Void) in
            guard let user = user else {
                respondWith(nil, nil, .badRequest)
                return
            }
            respondWith(1, user, nil)
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
                let updatedUser = User(id: id, name: userName, date: date)
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

        router.delete("/usersWithQueryParams") { (queryParams: UserQuery, respondWith: (RequestError?) -> Void) in
            self.userStore.forEach {
                if $1.name == queryParams.name {
                    self.userStore[$0] = nil
                }
            }
            respondWith(nil)
        }

        router.get("/usersWithQueryParams") { (queryParams: UserQuery, respondWith: ([User]?, RequestError?) -> Void) in
            let users = self.userStore.reduce([User]()) { acc, el in
                var acc = acc
                if el.value.name == queryParams.name {
                    acc.append(el.value)
                }
                return acc
            }
            respondWith(users, nil)
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

        // bodyerror routes
        router.get("/bodyerror") { (respondWith: ([User]?, RequestError?) -> Void) in respondWith(nil, RequestError(.conflict, body: Status("Boo"))) }
        router.get("/bodyerror") { (id: Int, respondWith: (User?, RequestError?) -> Void) in respondWith(nil, RequestError(.conflict, body: Status("Boo"))) }
        router.post("/bodyerror") { (user: User, respondWith: (User?, RequestError?) -> Void) in respondWith(nil, RequestError(.conflict, body: Status("Boo"))) }
        router.put("/bodyerror") { (id: Int, user: User, respondWith: (User?, RequestError?) -> Void) in respondWith(nil, RequestError(.conflict, body: Status("Boo"))) }
        router.patch("/bodyerror") { (id: Int, user: UserOptional, respondWith: (User?, RequestError?) -> Void) in respondWith(nil, RequestError(.conflict, body: Status("Boo"))) }
        router.delete("/bodyerror") { (id: Int, respondWith: (RequestError?) -> Void) in respondWith(RequestError(.conflict, body: Status("Boo"))) }
        router.delete("/bodyerror") { (respondWith: (RequestError?) -> Void) in respondWith(RequestError(.conflict, body: Status("Boo"))) }
    }

    private func setupBasicAuthRoutes() {
        // users routes
        router.get("/authusers")  { (profile: MyBasicAuth, respondWith: ([User]?, RequestError?) -> Void) in
            let users = self.userStore.map({ $0.value })
            respondWith(users, nil)
        }

        router.get("/authusers") { (profile: MyBasicAuth, id: Int, respondWith: (User?, RequestError?) -> Void) in
            guard let user = self.userStore[id.value] else {
                respondWith(nil, .notFound)
                return
            }
            respondWith(user, nil)
        }

        router.post("/authusers") { (profile: MyBasicAuth, user: User?, respondWith: (User?, RequestError?) -> Void) in
            guard let user = user else {
                respondWith(nil, .badRequest)
                return
            }
            self.userStore[String(user.id)] = user
            respondWith(user, nil)
        }

        router.post("/authusersid") { (profile: MyBasicAuth, user: User?, respondWith: (Int?, User?, RequestError?) -> Void) in
            guard let user = user else {
                respondWith(nil, nil, .badRequest)
                return
            }
            self.userStore[String(user.id)] = user
            respondWith(user.id, user, nil)
        }

        router.put("/authusers") { (profile: MyBasicAuth, id: Int, user: User?, respondWith: (User?, RequestError?) -> Void) in
            self.userStore[String(id)] = user
            respondWith(user, nil)
        }
        router.patch("/authusers") { (profile: MyBasicAuth, id: Int, user: UserOptional?, respondWith: (User?, RequestError?) -> Void) in
            guard let exisitingUser = self.userStore[id.value] else {
                respondWith(nil, .notFound)
                return
            }
            if let userName = user?.name {
                let updatedUser = User(id: id, name: userName, date: date)
                self.userStore[id.value] = updatedUser
                respondWith(updatedUser, nil)
            } else {
                respondWith(exisitingUser, nil)
            }
        }

        router.delete("/authusers") { (profile: MyBasicAuth, id: Int, respondWith: (RequestError?) -> Void) in
            guard let _ = self.userStore.removeValue(forKey: id.value) else {
                respondWith(.notFound)
                return
            }
            respondWith(nil)
        }

        router.delete("/authusers") { (profile: MyBasicAuth, respondWith: (RequestError?) -> Void) in
            self.userStore.removeAll()
            respondWith(nil)
        }

        router.delete("/authusersWithQueryParams") { (profile: MyBasicAuth, queryParams: UserQuery, respondWith: (RequestError?) -> Void) in
            self.userStore.forEach {
                if $1.name == queryParams.name {
                    self.userStore[$0] = nil
                }
            }
            respondWith(nil)
        }

        router.get("/authusersWithQueryParams") { (profile: MyBasicAuth, queryParams: UserQuery, respondWith: ([User]?, RequestError?) -> Void) in
            let users = self.userStore.reduce([User]()) { acc, el in
                var acc = acc
                if el.value.name == queryParams.name {
                    acc.append(el.value)
                }
                return acc
            }
            respondWith(users, nil)
        }
    }

    private func setupFacebookAuthRoutes() {
        // users routes
        router.get("/facebookusers")  { (profile: MyFacebookAuth, respondWith: ([User]?, RequestError?) -> Void) in
            let users = self.userStore.map({ $0.value })
            respondWith(users, nil)
        }

        router.get("/facebookusers") { (profile: MyFacebookAuth, id: Int, respondWith: (User?, RequestError?) -> Void) in
            guard let user = self.userStore[id.value] else {
                respondWith(nil, .notFound)
                return
            }
            respondWith(user, nil)
        }

        router.post("/facebookusers") { (profile: MyFacebookAuth, user: User?, respondWith: (User?, RequestError?) -> Void) in
            guard let user = user else {
                respondWith(nil, .badRequest)
                return
            }
            self.userStore[String(user.id)] = user
            respondWith(user, nil)
        }

        router.post("/facebookusersid") { (profile: MyFacebookAuth, user: User?, respondWith: (Int?, User?, RequestError?) -> Void) in
            guard let user = user else {
                respondWith(nil, nil, .badRequest)
                return
            }
            self.userStore[String(user.id)] = user
            respondWith(user.id, user, nil)
        }

        router.put("/facebookusers") { (profile: MyFacebookAuth, id: Int, user: User?, respondWith: (User?, RequestError?) -> Void) in
            self.userStore[String(id)] = user
            respondWith(user, nil)
        }
        router.patch("/facebookusers") { (profile: MyFacebookAuth, id: Int, user: UserOptional?, respondWith: (User?, RequestError?) -> Void) in
            guard let exisitingUser = self.userStore[id.value] else {
                respondWith(nil, .notFound)
                return
            }
            if let userName = user?.name {
                let updatedUser = User(id: id, name: userName, date: date)
                self.userStore[id.value] = updatedUser
                respondWith(updatedUser, nil)
            } else {
                respondWith(exisitingUser, nil)
            }
        }

        router.delete("/facebookusers") { (profile: MyFacebookAuth, id: Int, respondWith: (RequestError?) -> Void) in
            guard let _ = self.userStore.removeValue(forKey: id.value) else {
                respondWith(.notFound)
                return
            }
            respondWith(nil)
        }

        router.delete("/facebookusers") { (profile: MyFacebookAuth, respondWith: (RequestError?) -> Void) in
            self.userStore.removeAll()
            respondWith(nil)
        }

        router.delete("/facebookusersWithQueryParams") { (profile: MyFacebookAuth, queryParams: UserQuery, respondWith: (RequestError?) -> Void) in
            self.userStore.forEach {
                if $1.name == queryParams.name {
                    self.userStore[$0] = nil
                }
            }
            respondWith(nil)
        }

        router.get("/facebookusersWithQueryParams") { (profile: MyFacebookAuth, queryParams: UserQuery, respondWith: ([User]?, RequestError?) -> Void) in
            let users = self.userStore.reduce([User]()) { acc, el in
                var acc = acc
                if el.value.name == queryParams.name {
                    acc.append(el.value)
                }
                return acc
            }
            respondWith(users, nil)
        }
    }

    private func setupGoogleAuthRoutes() {
        // users routes
        router.get("/googleusers")  { (profile: MyGoogleAuth, respondWith: ([User]?, RequestError?) -> Void) in
            let users = self.userStore.map({ $0.value })
            respondWith(users, nil)
        }

        router.get("/googleusers") { (profile: MyGoogleAuth, id: Int, respondWith: (User?, RequestError?) -> Void) in
            guard let user = self.userStore[id.value] else {
                respondWith(nil, .notFound)
                return
            }
            respondWith(user, nil)
        }

        router.post("/googleusers") { (profile: MyGoogleAuth, user: User?, respondWith: (User?, RequestError?) -> Void) in
            guard let user = user else {
                respondWith(nil, .badRequest)
                return
            }
            self.userStore[String(user.id)] = user
            respondWith(user, nil)
        }

        router.post("/googleusersid") { (profile: MyGoogleAuth, user: User?, respondWith: (Int?, User?, RequestError?) -> Void) in
            guard let user = user else {
                respondWith(nil, nil, .badRequest)
                return
            }
            self.userStore[String(user.id)] = user
            respondWith(user.id, user, nil)
        }

        router.put("/googleusers") { (profile: MyGoogleAuth, id: Int, user: User?, respondWith: (User?, RequestError?) -> Void) in
            self.userStore[String(id)] = user
            respondWith(user, nil)
        }
        router.patch("/googleusers") { (profile: MyGoogleAuth, id: Int, user: UserOptional?, respondWith: (User?, RequestError?) -> Void) in
            guard let exisitingUser = self.userStore[id.value] else {
                respondWith(nil, .notFound)
                return
            }
            if let userName = user?.name {
                let updatedUser = User(id: id, name: userName, date: date)
                self.userStore[id.value] = updatedUser
                respondWith(updatedUser, nil)
            } else {
                respondWith(exisitingUser, nil)
            }
        }

        router.delete("/googleusers") { (profile: MyGoogleAuth, id: Int, respondWith: (RequestError?) -> Void) in
            guard let _ = self.userStore.removeValue(forKey: id.value) else {
                respondWith(.notFound)
                return
            }
            respondWith(nil)
        }

        router.delete("/googleusers") { (profile: MyGoogleAuth, respondWith: (RequestError?) -> Void) in
            self.userStore.removeAll()
            respondWith(nil)
        }

        router.delete("/googleusersWithQueryParams") { (profile: MyGoogleAuth, queryParams: UserQuery, respondWith: (RequestError?) -> Void) in
            self.userStore.forEach {
                if $1.name == queryParams.name {
                    self.userStore[$0] = nil
                }
            }
            respondWith(nil)
        }

        router.get("/googleusersWithQueryParams") { (profile: MyGoogleAuth, queryParams: UserQuery, respondWith: ([User]?, RequestError?) -> Void) in
            let users = self.userStore.reduce([User]()) { acc, el in
                var acc = acc
                if el.value.name == queryParams.name {
                    acc.append(el.value)
                }
                return acc
            }
            respondWith(users, nil)
        }
    }

    private func setupJWTAuthRoutes() {

        router.post("/generateJWT") { (user: JWTUser?, respondWith: (AccessToken?, RequestError?) -> Void) in
            guard let user = user else {
                respondWith(nil, .badRequest)
                return
            }
            var jwt = JWT(claims: ClaimsStandardJWT(iss: "Kitura", sub: user.name))
            guard let key = "<PrivateKey>".data(using: .utf8),
                let signedJWT = try? jwt.sign(using: .hs256(key: key))
                else {
                    return respondWith(nil, .internalServerError)
            }
            respondWith(AccessToken(accessToken: signedJWT), nil)
        }

        router.get("/protected") { (typeSafeJWT: MyJWTAuth<ClaimsStandardJWT>, respondWith: (JWTUser?, RequestError?) -> Void) in
            guard let userName = typeSafeJWT.jwt.claims.sub else {
                return respondWith(nil, .internalServerError)
            }
            respondWith(JWTUser(name: userName), nil)
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
