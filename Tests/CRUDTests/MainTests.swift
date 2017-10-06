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
import Kitura

@testable import CRUD

struct Employee: Codable {
    let id: String
    let name: String
}

extension Employee: Persistable {
    typealias I = String
}

class MainTests: XCTestCase {

//    static var allTests: [(String, (MainTests) -> () throws -> Void)] {
//        return [
//            ("testCreate", testCreate)
//        ]
//    }

    override func setUp() {
        super.setUp()

    }

    override func tearDown() {
        super.tearDown()
    }
    
//    No testing at the moment as the extension isn't working correctly right now (compliation error).
//    func testCreate() {
//
//        let expectation1 = expectation(description: "An employee is created successfully.")
//
//        let emp1 = Employee(id: "5", name: "Kye Maloy")
//        let emp2 = try Employee.create(model: emp1) { (emp: Employee) -> Void in
//            guard let emp = emp else {
//                XCTFail("Failed to create employee")
//            }
//
//            XCTAssertEqual(emp1, emp)
//            expectation1.fulfill()
//        }
//        waitForExpectations(timeout: 3.0, handler: nil)
//    }

}
