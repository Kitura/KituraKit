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

public class Controller {

    typealias Key = String

    public let router: Router

    private var userStore: [Key: User] = [:]

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    public init(store: [String: User]) {
        userStore = store
        router = Router()
        setupRoutes()
    }

    private func setupRoutes() {
        router.get("/users", handler: getUsers)
        router.get("/users/:id", handler: getUser)
        router.post("/users", handler: addUser)
        router.put("/users/:id", handler: addUser)
        router.patch("/users/:id", handler: updateUser)
        router.delete("/users/:id", handler: deleteUser)
        router.delete("/users", handler: deleteAll)
    }

    public func getUsers(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        let users = userStore.map { $1 }
        try response.status(.OK).send(data: encoder.encode(users)).end()
    }

    public func getUser(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        guard let id = request.parameters["id"] else {
            response.status(.badRequest)
            return
        }

        guard let user = userStore[id] else {
            response.status(.badRequest)
            return
        }

        try response.status(.OK).send(data: encoder.encode(user)).end()
    }

    public func addUser(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        do {
            var data = Data()
            _ = try request.read(into: &data)
            let user = try decoder.decode(User.self, from: data)
            userStore[String(user.id)] = user
            response.status(.OK).send(data: data)
        } catch {
            response.status(.internalServerError)
        }
    }

    public func updateUser(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
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
            response.status(.internalServerError)
        }
    }

    public func deleteAll(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        userStore = [:]
        response.status(.OK)
    }

    public func deleteUser(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        guard let id = request.parameters["id"] else {
            response.status(.badRequest)
            return
        }

        userStore[id] = nil
        response.status(.OK)
    }
    
}


