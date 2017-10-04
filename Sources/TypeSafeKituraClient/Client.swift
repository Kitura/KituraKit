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
                // Using nil value as the mechanism to let the user that 
                // an error occured...
                // Another approach could be to pass an error object also to resultHandler...
                // But... is that better? Using nil makes the API simpler...
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

    //TODO - Add addtional methods for PUT, DELETE, PATCH
    // TODO - Once we have completed basic type safe routing on the client, 
    // we will start tackling the CRUD API (which uses the Persistable protocol)

  /*    
    client.get(path: "/users/1") { (result: Employee?, error: Error?) in
    
    }
     */
    
    /*
    func get<ReturnType: Codable>(path: String, id: String, onCompletion: (ReturnType?, Error?) -> Void) {
        // construct the GET request
        
        let url = "\(serverURL)/\(path):\(id)"
        let requestParameters = RestRequest(method: .post,
                                            url: url,
                                            credentials: .apiKey)
        let request = RestRequest(requestParameters)
        request.responseData(responseToError: responseToError) { response in
            
            if let value = try? JSONDecoder.decode(ReturnType.self, data: responseData) {
                onCompletion(value, nil)
            } else {
                onCompletion(nil, RequestError(message: ""))
            }
            
        }
    }
    
    func getAll<ReturnType: Codable>(path: String, onCompletion: (ReturnType?, Error?) -> Void) {
        // construct the GET request
        
        let url = "\(serverURL)/\(path)"
        let requestParameters = RestRequest(method: .post,
                                            url: url,
                                            credentials: .apiKey)
        let request = RestRequest(requestParameters)
        request.responseData(responseToError: responseToError) { response in
            
            if let value = try? JSONDecoder.decode(ReturnType.self, data: responseData) {
                onCompletion(value, nil)
            } else {
                onCompletion(nil, RequestError(message: ""))
            }
            
        }
    }
    
    func post<ReturnType: Codable>(path: String, data: Codable, onCompletion: (ReturnType?, error?) -> Void) {
        // construct the POST request
        
        let url = "\(serverURL)/\(path)"
        let param = try JSONDecoder().decode(data.self, from: data)
        let requestParameters = RestRequest(method: .post,
                                            url: url,
                                            credentials: .apiKey,
                                            message: param)
        let request = RestRequest(requestParameters)
        request.responseData(responseToError: responseToError) { result in
            
            if let value = try? JSONEncoder.encode(result) {
                response.send(data: value)
            } else {
                response.status(.internalServerError)
            }
            
        }
    }
    
    func put<ReturnType: Codable>(path: String, id: String, data: Codable, onCompletion: (ReturnType?, error?) -> Void) {
        // construct the POST request
        
        let url = "\(serverURL)/\(path):\(id)"
        let param = try JSONDecoder().decode(data.self, from: data)
        let requestParameters = RestRequest(method: .post,
                                            url: url,
                                            credentials: .apiKey,
                                            message: param)
        let request = RestRequest(requestParameters)
        request.responseData(responseToError: responseToError) { result in
            
            if let value = try? JSONEncoder.encode(result) {
                response.send(data: value)
            } else {
                response.status(.internalServerError)
            }
            
        }
    }
    
    func delete<ReturnType: Codable>(path: String, id: String, onCompletion: (ReturnType?, error?) -> Void) {
        // construct the POST request
        
        let url = "\(serverURL)/\(path):\(id)"
        let requestParameters = RestRequest(method: .post,
                                            url: url,
                                            credentials: .apiKey)
        let request = RestRequest(requestParameters)
        request.responseData(responseToError: responseToError) { result in
            
            print(result)
            
        }
    }
    
    func deleteAll<ReturnType: Codable>(path: String, onCompletion: (ReturnType?, error?) -> Void) {
        // construct the POST request
        
        let url = "\(serverURL)/\(path)"
        let requestParameters = RestRequest(method: .post,
                                            url: url,
                                            credentials: .apiKey)
        let request = RestRequest(requestParameters)
        request.responseData(responseToError: responseToError) { result in
            
            print(result)
            
        }
    }
    */
    
}
