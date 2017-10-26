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

/// A client side library for using REST requests in a web application.
public class KituraKit {

    public typealias SimpleClosure = (RequestError?) -> Void
    public typealias CodableClosure<O: Codable> = (O?, RequestError?) -> Void
    public typealias ArrayCodableClosure<O: Codable> = ([O]?, RequestError?) -> Void

    /// Default URL used for setting up the routes when no URL is provided in the initializer.
    public static var defaultBaseURL: String = "http://localhost:8080"
    
    /// Default route used for setting up the paths based on the URL provided in the initializer.
    public static var `default`: KituraKit {
        get {
            return KituraKit(url: defaultBaseURL)
        }
    }

    /// Customisable URL used for setting up the routes when initializing a new KituraKit instance.
    public let baseURL: String

    // Initializers
    private init(url: String) {
        self.baseURL = url
    }

    /// An initializer to set up a custom KituraKit instance on a specified route.
    /// - Parameter baseURL: The custom route KituraKit points to during REST requests.
    public init?(baseURL: String) {
        let checkedUrl = checkMistypedURL(inputURL: baseURL)
        guard let _ = URL(string: checkedUrl) else {
            return nil
        }
        self.baseURL = checkedUrl
    }

    // HTTP verb/action methods (basic type safe routing)
    
    /// Retrieves data from a designated route.
    ///
    /// ### Usage Example: ###
    /// ````
    /// let client = KituraKit.default
    /// client.get("/") { (returnedArray: [O]?, error: Error?) -> Void in
    ///    print(returnedArray)
    /// }
    /// ````
    /// * This declaration of get retrieves all items. There is another declaration for specific item retrieval.
    ///
    /// - Parameter route: The custom route KituraKit points to during REST requests.
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

     /// Retrieves data from a designated route with an Identifier.
     ///
     /// ### Usage Example: ###
     /// ````
     /// let client = KituraKit.default
     /// client.get("/", identifier: Id) { (returnedItem: O?, error: Error?) -> Void in
     ///     print(returnedItem)
     /// }
     /// ````
     /// * This declaration of get retrieves single items. There is another declaration for all item retrieval.
     /// - Parameter route: The custom route KituraKit points to during REST requests.
     /// - Parameter identifier: The custom Identifier object that is searched for.
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

     /// Sends data to a designated route.
     ///
     /// ### Usage Example: ###
     /// ````
     /// let client = KituraKit.default
     /// client.post("/", data: dataToSend) { (returnedItem: O?, error: Error?) -> Void in
     ///     print(returnedItem)
     /// }
     /// ````
     /// - Parameter route: The custom route KituraKit points to during REST requests.
     /// - Parameter data: The custom Codable object passed in to be sent.
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
    
     /// Updates data for a designated route using an Identifier.
     ///
     /// ### Usage Example: ###
     /// ````
     /// let client = KituraKit.default
     /// client.put("/", identifier: Id, data: dataToSend) { (returnedItem: O?, error: Error?) -> Void in
     ///     print(returnedItem)
     /// }
     /// ````
     /// * This declaration uses the put method to update data.
     /// - Parameter route: The custom route KituraKit points to during REST requests.
     /// - Parameter identifier: The custom Identifier object that is searched for.
     /// - Parameter data: The custom Codable object passed in to be sent.
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
    
     /// Updates data for a designated route using an Identifier.
     ///
     /// ### Usage Example: ###
     /// ````
     /// let client = KituraKit.default
     /// client.patch("/", identifier: Id, data: dataToSend) { (returnedItem: O?, error: Error?) -> Void in
     ///     print(returnedItem)
     /// }
     /// ````
     /// * This declaration uses the patch method to update data.
     /// - Parameter route: The custom route KituraKit points to during REST requests.
     /// - Parameter identifier: The custom Identifier object that is searched for.
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
    
     /// Deletes data at a designated route.
     ///
     /// ### Usage Example: ###
     /// ````
     /// let client = KituraKit.default
     /// client.delete("/") { error in
     ///     print("Successfully deleted")
     /// }
     /// ````
     /// * This declaration of delete deletes all items. There is another declaration for single item deletion.
     /// - Parameter route: The custom route KituraKit points to during REST requests.
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
    
     /// Deletes data at a designated route using an Identifier.
     ///
     /// ### Usage Example: ###
     /// ````
     /// let client = KituraKit.default
     /// client.delete("/", identifier: urlToSend) { error in
     ///     print("Successfully deleted")
     /// }
     /// ````
     /// * This declaration of delete deletes single items. There is another declaration for all item deletion.
     /// - Parameter route: The custom route KituraKit points to during REST requests.
     /// - Parameter identifier: The custom Identifier object that is searched for.
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

 /// Checks for mistyped URLs for the client route path.
 ///
 /// ### Usage Example: ###
 /// ````
 /// let checkedUrl = checkMistypedURL(inputURL: baseURL)
 /// ````
 /// - Parameter inputURL: The string that is checked for mistypes.
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
