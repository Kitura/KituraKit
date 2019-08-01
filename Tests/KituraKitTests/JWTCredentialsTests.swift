/**
 * Copyright IBM Corporation 2019
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

class JWTCredentialsTests: XCTestCase {
    
    static var allTests: [(String, (JWTCredentialsTests) -> () throws -> Void)] {
        return [
            ("testNoCredentials", testNoCredentials),
            ("testIncorrectJWT", testIncorrectJWT),
            ("testCorrectJWT", testCorrectJWT),
        ]
    }
    
    private let client = KituraKit.default
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        client.defaultCredentials = JWTCredentials(token: "12345")

        // Reset state of server between tests
        let serverReset = expectation(description: "Server state was successfully reset")
        client.get("/reset") { (success: Status?, error: RequestError?) -> Void in
            XCTAssertNotNil(success, "Unable to reset server: \(error?.localizedDescription ?? "unknown error")")
            serverReset.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }

    // Checks that the server correctly rejects a request that doesn't supply any credentials
    func testNoCredentials() {
        
        let expectation1 = expectation(description: "A response from the server -> .unauthorized")
            client.get("protected") { (user: JWTUser?, error: RequestError?) in
                guard let error = error else {
                    XCTFail("Got users unexpectantly! Users: \(String(describing: user))")
                    return
                }
                XCTAssertEqual(error, .unauthorized)
                expectation1.fulfill()
            }
            waitForExpectations(timeout: 3.0, handler: nil)
    }
    
    // Checks that the server correctly rejects a request with invalid credentials
    func testIncorrectJWT() {
            
            let expectation1 = expectation(description: "A response from the server -> .unauthorized")
                client.get("protected", credentials: JWTCredentials(token: "wrongToken")) { (user: JWTUser?, error: RequestError?) in
                    guard let error = error else {
                        XCTFail("Got users unexpectantly! Users: \(String(describing: user))")
                        return
                    }
                    XCTAssertEqual(error, .unauthorized)
                    expectation1.fulfill()
                }
                waitForExpectations(timeout: 3.0, handler: nil)
        }
    
    // Checks that the server correctly accepts a request with valid credentials
    func testCorrectJWT() {
                
        let expectation1 = expectation(description: "A response from the server -> OK")
        let newUser = JWTUser(name: "Test")
        
        self.client.post("/generateJWT", data: newUser) { (token: AccessToken?, error: Error?) in
            guard let accessToken = token?.accessToken else {
                XCTFail("Bad Connection")
                return
            }
            
            self.client.get("protected", credentials: JWTCredentials(token: accessToken)) { (user: JWTUser?, error: RequestError?) in
                guard let user = user else {
                    XCTFail("Failed to get users! Error: \(String(describing: error))")
                    return
                }
                XCTAssertEqual(user, newUser)
                expectation1.fulfill()
            }
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }
}

