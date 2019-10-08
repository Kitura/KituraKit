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

import XCTest
import Foundation
import KituraContracts

@testable import KituraKit

class MainTests: XCTestCase {

    static var allTests: [(String, (MainTests) -> () throws -> Void)] {
        return [
            ("testClientGet", testClientGet),
            ("testClientGetErrorPath", testClientGetErrorPath),
            ("testClientGetSingleNoId", testClientGetSingleNoId),
            ("testClientGetSingle", testClientGetSingle),
            ("testClientGetSingleErrorPath", testClientGetSingleErrorPath),
            ("testClientPost", testClientPost),
            ("testClientPostWithIdentifier", testClientPostWithIdentifier),
            ("testClientPostErrorPath", testClientPostErrorPath),
            ("testClientPut", testClientPut),
            ("testClientPutErrorPath", testClientPutErrorPath),
            ("testClientPatch", testClientPatch),
            ("testClientPatchErrorPath", testClientPatchErrorPath),
            ("testClientDelete", testClientDelete),
            ("testClientDeleteSingle", testClientDeleteSingle),
            ("testClientDeleteInvalid", testClientDeleteInvalid),
            ("testSlashRemoval", testSlashRemoval),
            ("testUrlErrorCorrecting",testUrlErrorCorrecting),
            ("testUrlAddingHttp",testUrlAddingHttp),
            ("testClientGetErrorWithBodyPath", testClientGetErrorWithBodyPath),
            ("testClientGetSingleErrorWithBodyPath", testClientGetSingleErrorWithBodyPath),
            ("testClientPostErrorWithBodyPath", testClientPostErrorWithBodyPath),
            ("testClientPutErrorWithBodyPath", testClientPutErrorWithBodyPath),
            ("testClientPatchErrorWithBodyPath", testClientPatchErrorWithBodyPath),
            ("testClientDeleteSingleErrorWithBodyPath", testClientDeleteSingleErrorWithBodyPath),
            ("testClientDeleteErrorWithBodyPath", testClientDeleteErrorWithBodyPath)
        ]
    }

    private let client = KituraKit.default

    override func setUp() {
        super.setUp()
        continueAfterFailure = false

        // Reset state of server between tests
        let serverReset = expectation(description: "Server state was successfully reset")
        client.get("/reset") { (success: Status?, error: RequestError?) -> Void in
            XCTAssertNotNil(success, "Unable to reset server: \(error?.localizedDescription ?? "unknown error")")
            serverReset.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }

    func testClientGet() {
        let expectation1 = expectation(description: "A response is received from the server -> array of users")

        // Invoke GET operation on library
        client.get("/users") { (users: [User]?, error: RequestError?) -> Void in
            guard let users = users else {
                XCTFail("Failed to get users! Error: \(String(describing: error))")
                return
            }
            XCTAssertEqual(users.count, 5)
            expectation1.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }

    func testClientGetErrorPath() {
        let expectation1 = expectation(description: "An error is received from the server")

        // Invoke GET operation on library
        client.get("/notAValidRoute") { (users: [User]?, error: RequestError?) -> Void in
            if case .notFound? = error {
                expectation1.fulfill()
            } else {
                XCTFail("Failed to get expected error from server: \(String(describing: error))")
                return
            }
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }

    func testClientGetSingleNoId() {
        let expectation1 = expectation(description: "A response is received from the server -> user")

        // Invoke GET operation on library
        client.get("/health") { (status: Status?, error: RequestError?) -> Void in
            guard let status = status else {
                XCTFail("Failed to get status! Error: \(String(describing: error))")
                return
            }
            XCTAssertEqual(status.description, "GOOD")
            expectation1.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }

    func testClientGetSingle() {
        let expectation1 = expectation(description: "A response is received from the server -> user")

        // Invoke GET operation on library
        let id = "1"
        client.get("/users", identifier: id) { (user: User?, error: RequestError?) -> Void in
            guard let user = user else {
                XCTFail("Failed to get user! Error: \(String(describing: error))")
                return
            }
            XCTAssertEqual(user, initialStore[id]!)
            expectation1.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }

    func testClientGetSingleErrorPath() {
        let expectation1 = expectation(description: "An error is received from the server")

        // Invoke GET operation on library
        let id = "1"
        client.get("/notAValidRoute", identifier: id) { (users: User?, error: RequestError?) -> Void in
            if case .notFound? = error {
                expectation1.fulfill()
            } else {
                XCTFail("Failed to get expected error from server: \(String(describing: error))")
                return
            }
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }

    func testClientPost() {
        let expectation1 = expectation(description: "A response is received from the server -> user")

        // Invoke POST operation on library
        let newUser = User(id: 5, name: "John Doe", date: date)

        client.post("/users", data: newUser) { (user: User?, error: RequestError?) -> Void in
            guard let user = user else {
                XCTFail("Failed to post user! Error: \(String(describing: error))")
                return
            }

            XCTAssertEqual(user, newUser)
            expectation1.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }

    func testClientPostWithIdentifier() {
        let expectation1 = expectation(description: "A response is received from the server -> user")

        // Invoke POST operation on library
        let userId = 5
        let newUser = User(id: userId, name: "John Doe", date: date)

        client.post("/usersid", data: newUser) { (id: Int?, user: User?, error: RequestError?) -> Void in
            guard let user = user else {
                XCTFail("Failed to post user! Error: \(String(describing: error))")
                return
            }
            guard let id = id else {
                XCTFail("Failed to receive Identifier back from post")
                return
            }

            XCTAssertEqual(user, newUser)
            XCTAssertEqual(userId, id)
            expectation1.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }

    func testClientPostErrorPath() {
        let expectation1 = expectation(description: "An error is received from the server")

        // Invoke POST operation on library
        let newUser = User(id: 5, name: "John Doe", date: date)

        client.post("/notAValidRoute", data: newUser) { (users: User?, error: RequestError?) -> Void in
            if case .notFound? = error {
                expectation1.fulfill()
            } else {
                XCTFail("Failed to get expected error: \(String(describing: error))")
                return
            }
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }

    // Deliberately uses a type that is mismatched with the server, in order to decode more fields from a
    // response than the server has sent, leading to a decoding error.
    func testClientPostErrorObject() {
        
        let expectation1 = expectation(description: "An error is received from the server")
        let invalidUser = AugmentedUser(id: 5, name: "John Doe", date: date, age: 20)
        client.post("/invaliduser", data: invalidUser) { (id: Int?, returnedItem: AugmentedUser?, error: RequestError?) -> Void in
            let errorString = String(describing: error)
            // Can't access underlying error directly, so we check for evidence of the underlying error in the returned RequestError
            if errorString.contains("keyNotFound(CodingKeys(stringValue: \"age\", intValue: nil)") {
                expectation1.fulfill()
            } else {
                XCTFail("Failed to get expected error: \(String(describing: error))")
                return
            }
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }

    func testClientPut() {
        let expectation1 = expectation(description: "A response is received from the server -> user")

        // Invoke PUT operation on library
        let expectedUser = User(id: 5, name: "John Doe", date: date)

        client.put("/users", identifier: String(expectedUser.id), data: expectedUser) { (user: User?, error: RequestError?) -> Void in

            guard let user = user else {
                XCTFail("Failed to put user! Error: \(String(describing: error))")
                return
            }

            XCTAssertEqual(user, expectedUser)
            expectation1.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }

    func testClientPutErrorPath() {
        let expectation1 = expectation(description: "An error is received from the server")

        // Invoke PUT operation on library
        let expectedUser = User(id: 5, name: "John Doe", date: date)

        client.put("/notAValidRoute", identifier: String(expectedUser.id), data: expectedUser) { (users: User?, error: RequestError?) -> Void in
            if case .notFound? = error {
                expectation1.fulfill()
            } else {
                XCTFail("Failed to get expected error: \(String(describing: error))")
                return
            }
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }

    func testClientPatch() {
        let expectation1 = expectation(description: "A response is received from the server -> user")

        let expectedUser = User(id: 4, name: "John Doe", date: date)

        client.patch("/users", identifier: String(describing: expectedUser.id), data: expectedUser) { (user: User?, error: RequestError?) -> Void in
            guard let user = user else {
                XCTFail("Failed to patch user! Error: \(String(describing: error))")
                return
            }

            XCTAssertEqual(user, expectedUser)

            expectation1.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }

    func testClientPatchErrorPath() {
        let expectation1 = expectation(description: "An error is received from the server")
        let expectedUser = User(id: 4, name: "John Doe", date: date)

        client.patch("/notAValidRoute", identifier: String(describing: expectedUser.id), data: expectedUser) { (users: UserOptional?, error: RequestError?) -> Void in
            if case .notFound? = error {
                expectation1.fulfill()
            } else {
                XCTFail("Failed to get expected error from server: \(String(describing: error))")
                return
            }
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }

     func testClientDeleteSingle() {
        let expectation1 = expectation(description: "No error is received from the server")

        // Invoke GET operation on library
        client.delete("/users", identifier: "1") { error in
            guard error == nil else {
                XCTFail("Failed to delete user! Error: \(String(describing: error))")
                return
            }
            expectation1.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }

    // delete tests get executed first and cause get individual user tests to fail as the users have been deleted

    func testClientDelete() {
        let expectation1 = expectation(description: "No error is received from the server")

        client.delete("/users") { error in
            guard error == nil else {
                XCTFail("Failed to delete user! Error: \(String(describing: error))")
                return
            }

            expectation1.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }

    func testClientGetByQuery() {
        let expectation1 = expectation(description: "A response is received from the server -> array of users")

        let myQuery = UserQuery(name: "Mike")

        // Invoke GET operation on library
        client.get("/usersWithQueryParams", query: myQuery) { (users: [User]?, error: RequestError?) -> Void in
            guard let users = users else {
                XCTFail("Failed to get users! Error: \(String(describing: error))")
                return
            }
            XCTAssertEqual(users.count, 2)
            expectation1.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }

    func testClientDeleteByQuery() {
        let expectation1 = expectation(description: "No error is received from the server")

        let myQuery = UserQuery(name: "Mike")

        client.delete("/usersWithQueryParams", query: myQuery) { error in
            guard error == nil else {
                XCTFail("Failed to delete users! Error: \(String(describing: error))")
                return
            }

            expectation1.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }

    func testClientDeleteInvalid() {
        let expectation1 = expectation(description: "An error is received from the server")

        client.delete("/notAValidRoute") { error in
            if case .notFound? = error {
                expectation1.fulfill()
            } else {
                XCTFail("Failed to get expected error: \(String(describing: error))")
                return
            }
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }

    func testSlashRemoval() {
        let expectation1 = expectation(description: "A client is generated with the intentional ending slash being removed from the KituraKit baseURL.")

        let client = KituraKit(baseURL: "http://localhost:8080/")
        let correctedURL = "http://localhost:8080"

        XCTAssertEqual(correctedURL, client?.baseURL.absoluteString)
        expectation1.fulfill()

        waitForExpectations(timeout: 3.0, handler: nil)


    }

    func testUrlErrorCorrecting() {
        let expectation1 = expectation(description: "A client is generated with the baseURL changed to http://")

        let client = KituraKit(baseURL: "htttp://localhost:8080")
        let correctedURL = "http://localhost:8080"

        XCTAssertEqual(correctedURL, client?.baseURL.absoluteString)
        expectation1.fulfill()

        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testUrlAddingHttp() {
        let expectation1 = expectation(description: "A client is generated with http:// added to front of baseURL")

        let client = KituraKit(baseURL: "localhost:8080")
        let correctedURL = "http://localhost:8080"

        XCTAssertEqual(correctedURL, client?.baseURL.absoluteString)
        expectation1.fulfill()

        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testClientGetErrorWithBodyPath() {
        let expectation1 = expectation(description: "An error with body is received from the server")
        client.get("/bodyerror") { (users: [User]?, error: RequestError?) -> Void in
            XCTAssertNotNil(error, "Expected error but no error given")
            XCTAssertNil(users, "Unexpected success value given: \(String(describing: users))")
            if let error = error {
                XCTAssertEqual(RequestError.conflict.rawValue, error.rawValue)
                let body = error.bodyAs(Status.self)
                XCTAssertNotNil(body, "No body or body is not a Status")
                if let conflict = body {
                    XCTAssertEqual(Status("Boo"), conflict)
                }
            }
            expectation1.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }

    func testClientGetSingleErrorWithBodyPath() {
        let expectation1 = expectation(description: "An error with body is received from the server")
        client.get("/bodyerror", identifier: "1") { (user: User?, error: RequestError?) -> Void in
            XCTAssertNotNil(error, "Expected error but no error given")
            XCTAssertNil(user, "Unexpected success value given: \(String(describing: user))")
            if let error = error {
                XCTAssertEqual(RequestError.conflict.rawValue, error.rawValue)
                let body = error.bodyAs(Status.self)
                XCTAssertNotNil(body, "No body or body is not a Status")
                if let conflict = body {
                    XCTAssertEqual(Status("Boo"), conflict)
                }
            }
            expectation1.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }

    func testClientPostErrorWithBodyPath() {
        let expectation1 = expectation(description: "An error with body is received from the server")
        let newUser = User(id: 5, name: "John Doe", date: date)
        client.post("/bodyerror", data: newUser) { (user: User?, error: RequestError?) -> Void in
            XCTAssertNotNil(error, "Expected error but no error given")
            XCTAssertNil(user, "Unexpected success value given: \(String(describing: user))")
            if let error = error {
                XCTAssertEqual(RequestError.conflict.rawValue, error.rawValue)
                let body = error.bodyAs(Status.self)
                XCTAssertNotNil(body, "No body or body is not a Status")
                if let conflict = body {
                    XCTAssertEqual(Status("Boo"), conflict)
                }
            }
            expectation1.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }

    func testClientPutErrorWithBodyPath() {
        let expectation1 = expectation(description: "An error with body is received from the server")
        let userToUpdate = User(id: 5, name: "John Doe", date: date)
        client.put("/bodyerror",identifier: String(userToUpdate.id), data: userToUpdate) { (user: User?, error: RequestError?) -> Void in
            XCTAssertNotNil(error, "Expected error but no error given")
            XCTAssertNil(user, "Unexpected success value given: \(String(describing: user))")
            if let error = error {
                XCTAssertEqual(RequestError.conflict.rawValue, error.rawValue)
                let body = error.bodyAs(Status.self)
                XCTAssertNotNil(body, "No body or body is not a Status")
                if let conflict = body {
                    XCTAssertEqual(Status("Boo"), conflict)
                }
            }
            expectation1.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }

    func testClientPatchErrorWithBodyPath() {
        let expectation1 = expectation(description: "An error with body is received from the server")
        let userToUpdate = User(id: 4, name: "John Doe", date: date)
        client.patch("/bodyerror", identifier: String(describing: userToUpdate.id), data: userToUpdate) { (user: User?, error: RequestError?) -> Void in
            XCTAssertNotNil(error, "Expected error but no error given")
            XCTAssertNil(user, "Unexpected success value given: \(String(describing: user))")
            if let error = error {
                XCTAssertEqual(RequestError.conflict.rawValue, error.rawValue)
                let body = error.bodyAs(Status.self)
                XCTAssertNotNil(body, "No body or body is not a Status")
                if let conflict = body {
                    XCTAssertEqual(Status("Boo"), conflict)
                }
            }
            expectation1.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }

    func testClientDeleteSingleErrorWithBodyPath() {
        let expectation1 = expectation(description: "An error with body is received from the server")
        client.delete("/bodyerror", identifier: "1") { (error: RequestError?) -> Void in
            XCTAssertNotNil(error, "Expected error but no error given")
            if let error = error {
                XCTAssertEqual(RequestError.conflict.rawValue, error.rawValue)
                let body = error.bodyAs(Status.self)
                XCTAssertNotNil(body, "No body or body is not a Status")
                if let conflict = body {
                    XCTAssertEqual(Status("Boo"), conflict)
                }
            }
            expectation1.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }

    func testClientDeleteErrorWithBodyPath() {
        let expectation1 = expectation(description: "An error with body is received from the server")
        client.delete("/bodyerror") { (error: RequestError?) -> Void in
            XCTAssertNotNil(error, "Expected error but no error given")
            if let error = error {
                XCTAssertEqual(RequestError.conflict.rawValue, error.rawValue)
                let body = error.bodyAs(Status.self)
                XCTAssertNotNil(body, "No body or body is not a Status")
                if let conflict = body {
                    XCTAssertEqual(Status("Boo"), conflict)
                }
            }
            expectation1.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }
}
