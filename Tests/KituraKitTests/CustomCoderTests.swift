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

import XCTest
import Foundation
import Kitura
import KituraContracts

@testable import KituraKit

class CustomCoderTests: XCTestCase {
    
    static var allTests: [(String, (CustomCoderTests) -> () throws -> Void)] {
        return [
            ("testClientGet", testClientGet),
            ("testClientPost", testClientPost),
            ("testClientPut", testClientPut),
            ("testClientPatch", testClientPatch),
        ]
    }
    
    private let client = KituraKit.default
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        
        let controller = Controller(userStore: initialStore)
        let customEncoder: () -> BodyEncoder = {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .secondsSince1970
            return encoder
        }
        let customDecoder: () -> BodyDecoder = {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            return decoder
        }
        controller.router.encoders[MediaType(type: .application, subType: "custom")] = customEncoder
        controller.router.decoders[MediaType(type: .application, subType: "custom")] = customDecoder
        Kitura.addHTTPServer(onPort: 8080, with: controller.router)
        Kitura.start()
        client.encoder = Encoder(bodyEncoder: customEncoder, contentType: "application/custom")
        client.decoder = Decoder(bodyDecoder: customDecoder, accept: "application/custom")

    }
    
    override func tearDown() {
        Kitura.stop()
        super.tearDown()
    }
    
    func testClientGet() {
        let expectation1 = expectation(description: "A response is received from the server -> array of users")
        
        // Invoke GET operation on library
        client.get("/users") { (users: [User]?, error: RequestError?) -> Void in
            guard let users = users else {
                XCTFail("Failed to get users! Error: \(String(describing: error))")
                return
            }
            XCTAssertEqual(users[0].date, date)
            expectation1.fulfill()
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
}
