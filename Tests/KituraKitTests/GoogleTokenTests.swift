/**
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
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

#if os(Linux)
import Glibc
#else
import Darwin
#endif

import XCTest
import Foundation
import KituraContracts

@testable import KituraKit


class GoogleTokenTests: XCTestCase {
    
    static var allTests: [(String, (GoogleTokenTests) -> () throws -> Void)] {
        return [
            ("testGoogleTokenHeadersGet", testGoogleTokenHeadersGet),
            ("testGoogleTokenUnauthorized", testGoogleTokenUnauthorized),
            ("testGoogleTokenNoHeaders", testGoogleTokenNoHeaders),
            ("testGoogleTokenClientGet", testGoogleTokenClientGet),
            ("testGoogleTokenClientGetSingle", testGoogleTokenClientGetSingle),
            ("testGoogleTokenClientPost", testGoogleTokenClientPost),
            ("testGoogleTokenClientPostWithIdentifier", testGoogleTokenClientPostWithIdentifier),
            ("testGoogleTokenClientPut", testGoogleTokenClientPut),
            ("testGoogleTokenClientPatch", testGoogleTokenClientPatch),
            ("testGoogleTokenClientDelete", testGoogleTokenClientDelete),
            ("testGoogleTokenClientDeleteSingle", testGoogleTokenClientDeleteSingle),
        ]
    }
    
    private let client = KituraKit.default
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        client.defaultCredentials = GoogleToken(token: "12345")
        
        // Reset state of server between tests
        let serverReset = expectation(description: "Server state was successfully reset")
        client.get("/reset") { (success: Status?, error: RequestError?) -> Void in
            XCTAssertNotNil(success, "Unable to reset server: \(error?.localizedDescription ?? "unknown error")")
            serverReset.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }

    func testGoogleTokenHeadersGet() {
        let expectation1 = expectation(description: "A response is received from the server -> array of users")
        
        // Invoke GET operation on library
        client.get("/googleusers", credentials: GoogleToken(token: "12345")) { (users: [User]?, error: RequestError?) -> Void in
            guard let users = users else {
                XCTFail("Failed to get users! Error: \(String(describing: error))")
                return
            }
            XCTAssertEqual(users.count, 5)
            expectation1.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }
    
    func testGoogleTokenUnauthorized() {
        // Note: fails on Linux with Swift 5 due to: https://bugs.swift.org/browse/SR-10281 - fixed in 5.0.2.
        let expectation1 = expectation(description: "A response is received from the server -> .unauthorized")
        
        // Invoke GET operation on library
        client.get("/googleusers", credentials: GoogleToken(token: "wrongToken")) { (users: [User]?, error: RequestError?) -> Void in
            guard let error = error else {
                XCTFail("Got users unexpectantly! Users: \(String(describing: users))")
                return
            }
            XCTAssertEqual(error, .unauthorized)
            expectation1.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }
    
    func testGoogleTokenNoHeaders() {
        // Note: fails on Linux with Swift 5 due to: https://bugs.swift.org/browse/SR-10281 - fixed in 5.0.2.
        let expectation1 = expectation(description: "A response is received from the server -> .unauthorized")
        
        // Invoke GET operation on library
        client.get("/googleusers", credentials: NilCredentials()) { (users: [User]?, error: RequestError?) -> Void in
            guard let error = error else {
                XCTFail("Got users unexpectantly! Users: \(String(describing: users))")
                return
            }
            XCTAssertEqual(error, .unauthorized)
            expectation1.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }
    
    func testGoogleTokenClientGet() {
        let expectation1 = expectation(description: "A response is received from the server -> array of users")
    
        // Invoke GET operation on library
        client.get("/googleusers") { (users: [User]?, error: RequestError?) -> Void in
            guard let users = users else {
                XCTFail("Failed to get users! Error: \(String(describing: error))")
                return
            }
            XCTAssertEqual(users.count, 5)
            expectation1.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }

    func testGoogleTokenClientGetSingle() {
        let expectation1 = expectation(description: "A response is received from the server -> user")
        
        // Invoke GET operation on library
        let id = "1"
        client.get("/googleusers", identifier: id) { (user: User?, error: RequestError?) -> Void in
            guard let user = user else {
                XCTFail("Failed to get user! Error: \(String(describing: error))")
                return
            }
            XCTAssertEqual(user, initialStore[id]!)
            expectation1.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }

    func testGoogleTokenClientPost() {
        let expectation1 = expectation(description: "A response is received from the server -> user")
        
        // Invoke POST operation on library
        let newUser = User(id: 5, name: "John Doe", date: date)
        
        client.post("/googleusers", data: newUser) { (user: User?, error: RequestError?) -> Void in
            guard let user = user else {
                XCTFail("Failed to post user! Error: \(String(describing: error))")
                return
            }
            
            XCTAssertEqual(user, newUser)
            expectation1.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }

    func testGoogleTokenClientPostWithIdentifier() {
        let expectation1 = expectation(description: "A response is received from the server -> user")
        
        // Invoke POST operation on library
        let userId = 5
        let newUser = User(id: userId, name: "John Doe", date: date)
        
        client.post("/googleusersid", data: newUser) { (id: Int?, user: User?, error: RequestError?) -> Void in
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

    func testGoogleTokenClientPut() {
        let expectation1 = expectation(description: "A response is received from the server -> user")
        
        // Invoke PUT operation on library
        let expectedUser = User(id: 5, name: "John Doe", date: date)
        
        client.put("/googleusers", identifier: String(expectedUser.id), data: expectedUser) { (user: User?, error: RequestError?) -> Void in
            
            guard let user = user else {
                XCTFail("Failed to put user! Error: \(String(describing: error))")
                return
            }
            
            XCTAssertEqual(user, expectedUser)
            expectation1.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }

    func testGoogleTokenClientPatch() {
        let expectation1 = expectation(description: "A response is received from the server -> user")
        
        let expectedUser = User(id: 4, name: "John Doe", date: date)
        
        client.patch("/googleusers", identifier: String(describing: expectedUser.id), data: expectedUser) { (user: User?, error: RequestError?) -> Void in
            guard let user = user else {
                XCTFail("Failed to patch user! Error: \(String(describing: error))")
                return
            }
            
            XCTAssertEqual(user, expectedUser)
            
            expectation1.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }

    func testGoogleTokenClientDeleteSingle() {
        let expectation1 = expectation(description: "No error is received from the server")
        
        // Invoke GET operation on library
        client.delete("/googleusers", identifier: "1") { error in
            guard error == nil else {
                XCTFail("Failed to delete user! Error: \(String(describing: error))")
                return
            }
            expectation1.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }

    // delete tests get executed first and cause get individual user tests to fail as the users have been deleted

    func testGoogleTokenClientDelete() {
        let expectation1 = expectation(description: "No error is received from the server")
        
        client.delete("/googleusers") { error in
            guard error == nil else {
                XCTFail("Failed to delete user! Error: \(String(describing: error))")
                return
            }
            
            expectation1.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }

    func testGoogleTokenClientGetByQuery() {
        let expectation1 = expectation(description: "A response is received from the server -> array of users")
        
        let myQuery = UserQuery(name: "Mike")
        
        // Invoke GET operation on library
        client.get("/googleusersWithQueryParams", query: myQuery) { (users: [User]?, error: RequestError?) -> Void in
            guard let users = users else {
                XCTFail("Failed to get users! Error: \(String(describing: error))")
                return
            }
            XCTAssertEqual(users.count, 2)
            expectation1.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }

    func testGoogleTokenClientDeleteByQuery() {
        let expectation1 = expectation(description: "No error is received from the server")
        
        let myQuery = UserQuery(name: "Mike")
        
        client.delete("/googleusersWithQueryParams", query: myQuery) { error in
            guard error == nil else {
                XCTFail("Failed to delete users! Error: \(String(describing: error))")
                return
            }
            
            expectation1.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }
}
