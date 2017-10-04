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

import Foundation
import LoggerAPI
import SwiftyRequest

public class Client {

    // Define closures
    public typealias VoidClosure = () -> Void
    public typealias CodableClosure<O: Codable> = (O?) -> Void
    public typealias ArrayCodableClosure<O: Codable> = ([O]?) -> Void
    
    // Instance variables
    public let baseURL: String

    // Initializers   
    public init(baseURL: String) {
        self.baseURL = baseURL
    }

    // HTTP verb/action methods (basic type safe routing)
  
    // GET - basic type safe routing
    public func get<O: Codable>(_ route: String, resultHandler: @escaping ArrayCodableClosure<O>) {
        let url: String = baseURL + route
        let request = RestRequest(method: .get, url: url, acceptType: "application/json")
        request.responseData { response in
            switch response.result {
            case .success(let data):
                let items: [O]? = try? JSONDecoder().decode([O].self, from: data)
                resultHandler(items)               
            case .failure(let error):
                Log.error("GET failure: \(error)")
                resultHandler(nil)            
            }           
        }
    }
    
    // GET single - basic type safe routing
    public func get<I: Codable, O: Codable>(_ route: String, identifier: I, resultHandler: @escaping CodableClosure<O>) {
        let url: String = baseURL + route + "/:" + String(describing: identifier)
        let request = RestRequest(method: .get, url: url, acceptType: "application/json")
        request.responseData { response in
            switch response.result {
            case .success(let data):
                let items: O? = try? JSONDecoder().decode(O.self, from: data)
                resultHandler(items)
            case .failure(let error):
                Log.error("GET failure: \(error)")
                resultHandler(nil)
            }
        }
    }

    // POST - basic type safe routing
	public func post<I: Codable, O: Codable>(_ route: String, data: I, resultHandler: @escaping CodableClosure<O>) {
        let url: String = baseURL + route
        let encoded = try? JSONEncoder().encode(data)
        let request = RestRequest(method: .post, url: url, acceptType: "application/json", messageBody: encoded)
        request.responseData { response in
            switch response.result {
            case .success(let data):
                let item: O? = try? JSONDecoder().decode(O.self, from: data)
                resultHandler(item)               
            case .failure(let error):
                Log.error("POST failure: \(error)")
                resultHandler(nil)               
            }           
        }
    }
    
    // PUT - basic type safe routing
    public func put<I: Codable, II: Codable, O: Codable>(_ route: String, identifier: I, data: II, resultHandler: @escaping CodableClosure<O>) {
        let url: String = baseURL + route + "/:" + String(describing: identifier)
        let encoded = try? JSONEncoder().encode(data)
        let request = RestRequest(method: .put, url: url, acceptType: "application/json", messageBody: encoded)
        request.responseData { response in
            switch response.result {
            case .success(let data):
                let item: O? = try? JSONDecoder().decode(O.self, from: data)
                resultHandler(item)
            case .failure(let error):
                Log.error("PUT failure: \(error)")
                resultHandler(nil)
            }
        }
    }
    
    // PATCH - basic type safe routing
    public func patch<I: Codable, II: Codable, O: Codable>(_ route: String, identifier: I, data: II, resultHandler: @escaping CodableClosure<O>) {
        let url: String = baseURL + route + "/:" + String(describing: identifier)
        let encoded = try? JSONEncoder().encode(data)
        let request = RestRequest(method: .patch, url: url, acceptType: "application/json", messageBody: encoded)
        request.responseData { response in
            switch response.result {
            case .success(let data):
                let item: O? = try? JSONDecoder().decode(O.self, from: data)
                resultHandler(item)
            case .failure(let error):
                Log.error("PATCH failure: \(error)")
                resultHandler(nil)
            }
        }
    }
    
    // DELETE - basic type safe routing
    public func delete(_ route: String, resultHandler: @escaping VoidClosure) {
        let url: String = baseURL + route
        let request = RestRequest(method: .delete, url: url, acceptType: "application/json")
        request.responseData { response in
            switch response.result {
            case .success(let data):
                resultHandler()
            case .failure(let error):
                Log.error("DELETE failure: \(error)")
                resultHandler()
            }
        }
    }
    
    // DELETE single - basic type safe routing
    public func delete<I: Codable>(_ route: String, identifier: I, resultHandler: @escaping VoidClosure) {
        let url: String = baseURL + route + "/:" + String(describing: identifier)
        let request = RestRequest(method: .delete, url: url, acceptType: "application/json")
        request.responseData { response in
            switch response.result {
            case .success(let data):
                resultHandler()
            case .failure(let error):
                Log.error("DELETE failure: \(error)")
                resultHandler()
            }
        }
    }

    // TODO - Once we have completed basic type safe routing on the client, 
    // we will start tackling the CRUD API (which uses the Persistable protocol)
    
}
