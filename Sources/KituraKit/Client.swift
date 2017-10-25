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
import KituraContracts

public class KituraKit {

    public typealias SimpleClosure = (RequestError?) -> Void
    public typealias CodableClosure<O: Codable> = (O?, RequestError?) -> Void
    public typealias ArrayCodableClosure<O: Codable> = ([O]?, RequestError?) -> Void

    public static var defaultBaseURL: String = "http://localhost:8080"
    public static var `default`: KituraKit {
        get {
            return KituraKit(url: defaultBaseURL)
        }
    }

    // Instance variables
    public let baseURL: String

    // Initializers
    private init(url: String) {
        self.baseURL = url
    }

    public init?(baseURL: String) {
        let checkedUrl = checkMistypedURL(inputURL: baseURL)
        guard let _ = URL(string: checkedUrl) else {
            return nil
        }
        self.baseURL = checkedUrl
    }

    // HTTP verb/action methods (basic type safe routing)

    // GET - basic type safe routing
    public func get<O: Codable>(_ route: String, respondWith: @escaping ArrayCodableClosure<O>) {
        let url: String = baseURL + route
        let request = RestRequest(url: url)
        request.responseData { response in
            switch response.result {
            case .success(let data):
                guard let items: [O] = try? JSONDecoder().decode([O].self, from: data) else {
                    respondWith(nil, RequestError.clientDeserializationError)
                    return
                }
                respondWith(items, nil)
            case .failure(let error):
                Log.error("GET failure: \(error)")
                if let restError = error as? RestError {
                    respondWith(nil, RequestError(restError: restError))
                } else {
                    respondWith(nil, .clientErrorUnknown)
                }
            }
        }
    }

    // GET single - basic type safe routing
    public func get<O: Codable>(_ route: String, identifier: Identifier, respondWith: @escaping CodableClosure<O>) {
        let url: String = baseURL + route + "/\(identifier)"
        let request = RestRequest(url: url)

        request.responseData { response in
            switch response.result {
            case .success(let data):
                guard let items: O = try? JSONDecoder().decode(O.self, from: data) else {
                    respondWith(nil, RequestError.clientDeserializationError)
                    return
                }
                respondWith(items, nil)
            case .failure(let error):
                Log.error("GET (single) failure: \(error)")
                if let restError = error as? RestError {
                    respondWith(nil, RequestError(restError: restError))
                } else {
                    respondWith(nil, .clientErrorUnknown)
                }
            }
        }
    }

    // POST - basic type safe routing
    public func post<I: Codable, O: Codable>(_ route: String, data: I, respondWith: @escaping CodableClosure<O>) {
        let url: String = baseURL + route
        let encoded = try? JSONEncoder().encode(data)
        let request = RestRequest(method: .post, url: url)
        request.messageBody = encoded

        request.responseData { response in
            switch response.result {
            case .success(let data):
                guard let item: O = try? JSONDecoder().decode(O.self, from: data) else {
                    respondWith(nil, RequestError.clientDeserializationError)
                    return
                }
                respondWith(item, nil)
            case .failure(let error):
                Log.error("POST failure: \(error)")
                if let restError = error as? RestError {
                    respondWith(nil, RequestError(restError: restError))
                } else {
                    respondWith(nil, .clientErrorUnknown)
                }
            }
        }
    }

    // PUT - basic type safe routing
    public func put<I: Codable, O: Codable>(_ route: String, identifier: Identifier, data: I, respondWith: @escaping CodableClosure<O>) {
        let url: String = baseURL + route + "/\(identifier)"
        let encoded = try? JSONEncoder().encode(data)
        let request = RestRequest(method: .put, url: url)
        request.messageBody = encoded

        request.responseData { response in
            switch response.result {
            case .success(let data):
                guard let item: O = try? JSONDecoder().decode(O.self, from: data) else {
                    respondWith(nil, RequestError.clientDeserializationError)
                    return
                }
                respondWith(item, nil)
            case .failure(let error):
                Log.error("PUT failure: \(error)")
                if let restError = error as? RestError {
                    respondWith(nil, RequestError(restError: restError))
                } else {
                    respondWith(nil, .clientErrorUnknown)
                }
            }
        }
    }

    // PATCH - basic type safe routing
    public func patch<I: Codable, O: Codable>(_ route: String, identifier: Identifier, data: I, respondWith: @escaping CodableClosure<O>) {
        let url: String = baseURL + route + "/\(identifier)"
        let encoded = try? JSONEncoder().encode(data)
        let request = RestRequest(method: .patch, url: url)
        request.messageBody = encoded

        request.responseData { response in
            switch response.result {
            case .success(let data):
                guard let item: O = try? JSONDecoder().decode(O.self, from: data) else {
                    respondWith(nil, RequestError.clientDeserializationError)
                    return
                }
                respondWith(item, nil)
            case .failure(let error):
                Log.error("PATCH failure: \(error)")
                if let restError = error as? RestError {
                    respondWith(nil, RequestError(restError: restError))
                } else {
                    respondWith(nil, .clientErrorUnknown)
                }
            }
        }
    }

    // DELETE - basic type safe routing
    public func delete(_ route: String, respondWith: @escaping SimpleClosure) {
        let url: String = baseURL + route
        let request = RestRequest(method: .delete, url: url)
        request.responseData { response in
            switch response.result {
            case .success:
                respondWith(nil)
            case .failure(let error):
                Log.error("DELETE failure: \(error)")
                if let restError = error as? RestError {
                    respondWith(RequestError(restError: restError))
                } else {
                    respondWith(.clientErrorUnknown)
                }
            }
        }
    }

    // DELETE single - basic type safe routing
    public func delete(_ route: String, identifier: Identifier, respondWith: @escaping SimpleClosure) {
        let url: String = baseURL + route + "/\(identifier)"
        let request = RestRequest(method: .delete, url: url)
        request.responseData { response in
            switch response.result {
            case .success:
                respondWith(nil)
            case .failure(let error):
                Log.error("DELETE failure: \(error)")
                if let restError = error as? RestError {
                    respondWith(RequestError(restError: restError))
                } else {
                    respondWith(.clientErrorUnknown)
                }
            }
        }
    }    
}

//Check an input URL begins with http:// or https:// and fix common mistypes
private func checkMistypedURL(inputURL: String) -> String {
    let mistypes = ["http:/","http:","http","htp://","ttp://","htttp://","htpp://","http//","htt://","http:://","http:///","httpp://","hhttp://","htt:"]
    //if necessary, trim extra back slash
    var noSlashUrl: String = inputURL.last == "/" ? String(inputURL.dropLast()) : inputURL
    if String(noSlashUrl.characters.prefix(7)).lowercased() == "http://" || String(noSlashUrl.characters.prefix(8)).lowercased() == "https://"{
        if String(noSlashUrl.characters.prefix(8)).lowercased() != "http:///" {
            return noSlashUrl
        }
    }
    //search the first 8 - 4 charecters for matching mistypes and replace with http://
    for i in (4...8).reversed() {
        for item in mistypes{
            if String(noSlashUrl.characters.prefix(i)).lowercased() == item {
                let processedUrl = noSlashUrl.dropFirst(i)
                return "http://\(processedUrl)"
            }
        }
    }
    //if no matching mistypes just add http:// to the front
    return "http://\(noSlashUrl)"
}
