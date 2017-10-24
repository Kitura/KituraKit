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
import SafetyContracts

public class KituraBuddy {

    public typealias SimpleClosure = (ProcessHandlerError?) -> Void
    public typealias CodableClosure<O: Codable> = (O?, ProcessHandlerError?) -> Void
    public typealias ArrayCodableClosure<O: Codable> = ([O]?, ProcessHandlerError?) -> Void

    public static var defaultBaseURL: String = "http://localhost:8080"
    public static var `default`: KituraBuddy {
        get {
            return KituraBuddy(baseURL: defaultBaseURL)
        }
    }

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
        let request = RestRequest(url: url)
        request.responseData { response in
            switch response.result {
            case .success(let data):
                guard let items: [O] = try? JSONDecoder().decode([O].self, from: data) else {
                    resultHandler(nil, ProcessHandlerError.clientDeserializationError)
                    return
                }
                resultHandler(items, nil)
            case .failure(let error):
                Log.error("GET failure: \(error)")
                if let restError = error as? RestError {
                    resultHandler(nil, ProcessHandlerError(restError: restError))
                } else {
                    resultHandler(nil, .clientErrorUnknown)
                }
            }
        }
    }

    // GET single - basic type safe routing
    public func get<O: Codable>(_ route: String, identifier: Identifier, resultHandler: @escaping CodableClosure<O>) {
        let url: String = baseURL + route + "/\(identifier)"
        let request = RestRequest(url: url)

        request.responseData { response in
            switch response.result {
            case .success(let data):
                guard let items: O = try? JSONDecoder().decode(O.self, from: data) else {
                    resultHandler(nil, ProcessHandlerError.clientDeserializationError)
                    return
                }
                resultHandler(items, nil)
            case .failure(let error):
                Log.error("GET (single) failure: \(error)")
                if let restError = error as? RestError {
                    resultHandler(nil, ProcessHandlerError(restError: restError))
                } else {
                    resultHandler(nil, .clientErrorUnknown)
                }
            }
        }
    }

    // POST - basic type safe routing
    public func post<I: Codable, O: Codable>(_ route: String, data: I, resultHandler: @escaping CodableClosure<O>) {
        let url: String = baseURL + route
        let encoded = try? JSONEncoder().encode(data)
        let request = RestRequest(method: .post, url: url)
        request.messageBody = encoded

        request.responseData { response in
            switch response.result {
            case .success(let data):
                guard let item: O = try? JSONDecoder().decode(O.self, from: data) else {
                    resultHandler(nil, ProcessHandlerError.clientDeserializationError)
                    return
                }
                resultHandler(item, nil)
            case .failure(let error):
                Log.error("POST failure: \(error)")
                if let restError = error as? RestError {
                    resultHandler(nil, ProcessHandlerError(restError: restError))
                } else {
                    resultHandler(nil, .clientErrorUnknown)
                }
            }
        }
    }

    // PUT - basic type safe routing
    public func put<I: Codable, O: Codable>(_ route: String, identifier: Identifier, data: I, resultHandler: @escaping CodableClosure<O>) {
        let url: String = baseURL + route + "/\(identifier)"
        let encoded = try? JSONEncoder().encode(data)
        let request = RestRequest(method: .put, url: url)
        request.messageBody = encoded

        request.responseData { response in
            switch response.result {
            case .success(let data):
                guard let item: O = try? JSONDecoder().decode(O.self, from: data) else {
                    resultHandler(nil, ProcessHandlerError.clientDeserializationError)
                    return
                }
                resultHandler(item, nil)
            case .failure(let error):
                Log.error("PUT failure: \(error)")
                if let restError = error as? RestError {
                    resultHandler(nil, ProcessHandlerError(restError: restError))
                } else {
                    resultHandler(nil, .clientErrorUnknown)
                }
            }
        }
    }

    // PATCH - basic type safe routing
    public func patch<I: Codable, O: Codable>(_ route: String, identifier: Identifier, data: I, resultHandler: @escaping CodableClosure<O>) {
        let url: String = baseURL + route + "/\(identifier)"
        let encoded = try? JSONEncoder().encode(data)
        let request = RestRequest(method: .patch, url: url)
        request.messageBody = encoded

        request.responseData { response in
            switch response.result {
            case .success(let data):
                guard let item: O = try? JSONDecoder().decode(O.self, from: data) else {
                    resultHandler(nil, ProcessHandlerError.clientDeserializationError)
                    return
                }
                resultHandler(item, nil)
            case .failure(let error):
                Log.error("PATCH failure: \(error)")
                if let restError = error as? RestError {
                    resultHandler(nil, ProcessHandlerError(restError: restError))
                } else {
                    resultHandler(nil, .clientErrorUnknown)
                }
            }
        }
    }

    // DELETE - basic type safe routing
    public func delete(_ route: String, resultHandler: @escaping SimpleClosure) {
        let url: String = baseURL + route
        let request = RestRequest(method: .delete, url: url)
        request.responseData { response in
            switch response.result {
            case .success:
                resultHandler(nil)
            case .failure(let error):
                Log.error("DELETE failure: \(error)")
                if let restError = error as? RestError {
                    resultHandler(ProcessHandlerError(restError: restError))
                } else {
                    resultHandler(.clientErrorUnknown)
                }
            }
        }
    }

    // DELETE single - basic type safe routing
    public func delete(_ route: String, identifier: Identifier, resultHandler: @escaping SimpleClosure) {
        let url: String = baseURL + route + "/\(identifier)"
        let request = RestRequest(method: .delete, url: url)
        request.responseData { response in
            switch response.result {
            case .success:
                resultHandler(nil)
            case .failure(let error):
                Log.error("DELETE failure: \(error)")
                if let restError = error as? RestError {
                    resultHandler(ProcessHandlerError(restError: restError))
                } else {
                    resultHandler(.clientErrorUnknown)
                }
            }
        }
    }
}
