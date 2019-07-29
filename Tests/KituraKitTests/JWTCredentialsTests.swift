//
//  File.swift
//  
//
//  Created by Cameron McWilliam on 25/07/2019.
//
#if os(Linux)
import Glibc
#else
import Darwin
#endif

import XCTest
import Foundation
import Kitura
import KituraContracts
import Dispatch

@testable import KituraKit

class JWTCredentialsTests: XCTestCase {
    
    static var alltests: [(String, (JWTCredentialsTests) -> () throws -> Void)] {
        
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
        let controller = Controller(userStore: initialStore)
        Kitura.addHTTPServer(onPort: 8080, with: controller.router)
        Kitura.start()
        
    }
    
    override func tearDown() {
        Kitura.stop()
        super.tearDown()
    }
    
    // This test checks that the server correctly rejects a request that doesn't supply any credentials
    
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
    
    // This test checks that the server correctly rejects a request with invalid credentials
    
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
    
    // This test checks that the server correctly accepts a request with valid credentials
    
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

