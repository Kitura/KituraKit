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
import SafetyContracts

@testable import KituraBuddy

extension Employee: Persistable {
    // Users of this library should only have to make their 
    // models conform to Persistable protocol by adding this extension
    // and specify the concrete type for the Identifier
    // Note that the Employee structure definition in a real
    // world case would be shared between the server and the client.
    public typealias Id = Int
}

class PersistableTests: XCTestCase {
    
        static var allTests: [(String, (PersistableTests) -> () throws -> Void)] {
            return [
                ("testCreate", testCreate),
                ("testRead", testRead),
                ("testReadAll", testReadAll),
                ("testUpdate", testUpdate),
                ("testDelete", testDelete),
                ("testDeleteAll", testDeleteAll)
            ]
        }
    
    private let controller = Controller(userStore: initialStore, employeeStore: initialStoreEmployee)
    
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        
        Kitura.addHTTPServer(onPort: 8080, with: controller.router)
        Kitura.start()
        
    }
    
    override func tearDown() {
        Kitura.stop()
        super.tearDown()
    }
    
    func testCreate() {
        let expectation1 = expectation(description: "An employee is created successfully.")
        let newEmployee = Employee(id: "5", name: "Kye Maloy")
        
        Employee.create(model: newEmployee) { (emp: Employee?, error: Error?) -> Void in
            if error != nil {
                XCTFail("Failed to create employee! \(error!)")
                return
            }
            guard let emp = emp else {
                XCTFail("Failed to create employee! \(error!)")
                return
            }
            XCTAssertEqual(newEmployee, emp)
            expectation1.fulfill()
        }
        
        waitForExpectations(timeout: 3.0, handler: nil)
    }
    
    func testRead() {
        let expectation1 = expectation(description: "An employee is read successfully.")
        
        Employee.read(id: 4) { (emp: Employee?, error: Error?) -> Void in
            
            if error != nil {
                XCTFail("Failed to read employee! \(error!)")
                return
            }
            guard emp != nil else {
                XCTFail("Failed to read employee! \(error!)")
                return
            }
 
            expectation1.fulfill()
        }
        
        waitForExpectations(timeout: 3.0, handler: nil)
    }
    
    func testReadAll() {
        let expectation1 = expectation(description: "All employees are read successfully.")
        
        Employee.read() { (emp: [Employee]?, error: Error?) -> Void in
            if error != nil {
                XCTFail("Failed to read employees! \(error!)")
                return
            }
            guard emp != nil else {
                XCTFail("Failed to read employees! \(error!)")
                return
            }
            expectation1.fulfill()
        }
        
        waitForExpectations(timeout: 3.0, handler: nil)
    }
    
    func testUpdate() {
        let expectation1 = expectation(description: "An employee is updated successfully.")
        let newEmployee = Employee(id: "5", name: "Kye Maloy")
        
        Employee.update(id: 5, model: newEmployee) { (emp: Employee?, error: Error?) -> Void in
            if error != nil {
                XCTFail("Failed to update employees! \(error!)")
                return
            }
            guard emp != nil else {
                XCTFail("Failed to update employees! \(error!)")
                return
            }
            expectation1.fulfill()
        }
        
        waitForExpectations(timeout: 3.0, handler: nil)
    }
    
    func testDelete() {
        let expectation1 = expectation(description: "An employee is deleted successfully.")
        
        Employee.delete(id: 5) { (error: Error?) -> Void in
            if error != nil {
                XCTFail("Failed to delete employee! \(error!)")
                return
            }
            expectation1.fulfill()
        }
        
        waitForExpectations(timeout: 3.0, handler: nil)
    }
    
    func testDeleteAll() {
        let expectation1 = expectation(description: "All employees are deleted successfully.")
        
        Employee.delete() { (error: Error?) -> Void in
            if error != nil {
                XCTFail("Failed to delete all employees! \(error!)")
                return
            }
            expectation1.fulfill()
        }
        
        waitForExpectations(timeout: 3.0, handler: nil)
    }
}
