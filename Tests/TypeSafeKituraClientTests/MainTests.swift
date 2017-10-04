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

#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

import XCTest
import Foundation

@testable import TypeSafeKituraClient

// Models/entities
public struct User: Codable {
    public let id: Int
    public let name: String
    public init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}

class MainTests: XCTestCase {

  static var allTests: [(String, (MainTests) -> () throws -> Void)] {
    return [
      ("testClientGet", testClientGet),
      ("testClientPost", testClientPost)
    ]
  }


  override func setUp() {
    super.setUp()
  }

  override func tearDown() {
    super.tearDown()
  }

  // TODO: See test cases we implemented for Kitura-Starter (we may need something similar)
  // https://github.com/IBM-Bluemix/Kitura-Starter/blob/master/Tests/ControllerTests/RouteTests.swift
  // I don't see a way to specify test-only dependencies... they removed this capability 
  // Hence, we may need to add Kitura as a dependency just for testing...
  // :-/ Not good to have to add a dependency to Package.swift when it is only neede for testing... but
  // that may be the option unless we want to mockup our own server, which may create unnecessary work for us.

  // Note that as of now, given how the tests are written, they will fail, UNLESS you have a kitura server running
  // locally that can process the requests.

  func testClientGet() {
    // TODO - needs improvement
    let expectation1 = expectation(description: "A response is received from the server -> array of users")
    // Define client
    let client = Client(baseURL: "http://localhost:8080")
    // Invoke GET operation on library
    client.get("/users") { (users: [User]?) -> Void in
      guard let users = users else {
        XCTFail("Failed to get users!")
        expectation1.fulfill()
        return
      }
      print("Users: \(users)")
      expectation1.fulfill()
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }

   func testClientPost() {
    // TODO - needs improvement
    let expectation1 = expectation(description: "A response is received from the server -> user")
    // Define client
    let client = Client(baseURL: "http://localhost:8080")
    // Invoke GET operation on library
    let expectedUser = User(id: 10, name: "John Doe")
    client.post("/users", data: expectedUser) { (user: User?) -> Void in
      guard let user = user else {
        XCTFail("Failed to post user!")
        expectation1.fulfill()
        return
      }
      print("User: \(user)")
      XCTAssertEqual(user.id, expectedUser.id)
      XCTAssertEqual(user.name, expectedUser.name)
      expectation1.fulfill()
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }

  //TODO - Add additional test cases

}