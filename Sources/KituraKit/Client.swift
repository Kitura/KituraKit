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

    // MARK: Default Parameters
    
    /// Default URL used for setting up the routes when no URL is provided in the initializer.
    public static var defaultBaseURL = URL(string: "http://localhost:8080")!

    /// Default route used for setting up the paths based on the URL provided in the initializer.
    public static var `default`: KituraKit {
        get {
            return KituraKit(baseURL: defaultBaseURL)
        }
    }

    /// Customisable URL used for setting up the routes when initializing a new KituraKit instance.
    public let baseURL: URL

    /// User credentials that will be used for authentication if none are provided to the route.
    /// ### Usage Example: ###
    /// ```swift
    /// let client = KituraKit.default
    /// client.defaultCredentials = HTTPBasic(username: "John", password: "12345")
    /// ```
    public var defaultCredentials: ClientCredentials?

    // Check if there exists a self-signed certificate
    private let containsSelfSignedCert: Bool

    // The client certificate for 2-way SSL
    private let clientCertificate: SwiftyRequest.ClientCertificate?
    
    // MARK: Custom Coding Format
    
    /**
     The `BodyEncoder` that will be used to encode the Codable object.
     ### Usage Example:
     ```swift
     let client = KituraKit.default
     let encoder = JSONEncoder()
     encoder.dateEncodingStrategy = .secondsSince1970
     client.encoder = encoder
     ```
     */
    public var encoder: BodyEncoder = JSONEncoder() 
    
    /**
     The `BodyDecoder` that will be used to decode the response Codable object.
     ### Usage Example:
     ```swift
     let client = KituraKit.default
     let decoder = JSONDecoder()
     decoder.dateDecodingStrategy = .secondsSince1970
     client.decoder = decoder
     ```
     */
    public var decoder: BodyDecoder = JSONDecoder()
    
    /**
     The `String` that will be used for the Content-Type and Accept headers in the HTTP requests.
     ### Usage Example:
     ```swift
     let client = KituraKit.default
     client.mediaType = "application/xml"
     ```
     */
    public var mediaType: String = "application/json"
    
    // MARK: Initializers
    
    /// An initializer to set up a custom KituraKit instance on a specified route using a URL
    /// - Parameters:
    ///   - baseURL: The custom route KituraKit points to during REST requests.
    ///   - containsSelfSignedCert: Pass `True` to use self signed certificates
    ///   - clientCertificate: Pass in `ClientCertificate` with the certificate name and path to use client certificates for 2-way SSL
    public init(baseURL: URL, containsSelfSignedCert: Bool = false, clientCertificate: ClientCertificate? = nil) {
        self.baseURL = baseURL
        if let clientCertificate = clientCertificate {
            self.clientCertificate = SwiftyRequest.ClientCertificate(name: clientCertificate.name, path: clientCertificate.path)
        } else {
            self.clientCertificate = nil
        }
        self.containsSelfSignedCert = containsSelfSignedCert
    }

    /// An initializer to set up a custom KituraKit instance on a specified route.
    /// - Parameters:
    ///   - baseURL: The custom route KituraKit points to during REST requests.
    ///   - containsSelfSignedCert: Pass `True` to use self signed certificates
    ///   - clientCertificate: Pass in `ClientCertificate` with the certificate name and path to use client certificates for 2-way SSL
    /// - Returns: nil if invalid URL. Otherwise return a KituraKit object
    public convenience init?(baseURL: String, containsSelfSignedCert: Bool = false, clientCertificate: ClientCertificate? = nil) {
        //if necessary, trim extra back slash
        let noSlashUrl: String = baseURL.last == "/" ? String(baseURL.dropLast()) : baseURL
        let checkedUrl = checkMistypedProtocol(inputURL: noSlashUrl)
        guard let url = URL(string: checkedUrl) else {
            return nil
        }
        self.init(baseURL: url, containsSelfSignedCert: containsSelfSignedCert, clientCertificate: clientCertificate)
    }

    // MARK: HTTP type safe routing

    /// Retrieves data from a designated route.
    ///
    /// ### Usage Example: ###
    /// ````
    /// struct User: Codable {
    ///     ...
    /// }
    ///
    /// let client = KituraKit.default
    /// client.get("/") { (returnedArray: [User]?, error: Error?) -> Void in
    ///    print(returnedArray)
    /// }
    /// ````
    /// * This declaration of get retrieves all items. There is another declaration for specific item retrieval.
    ///
    /// - Parameter route: The custom route KituraKit points to during REST requests.
    public func get<O: Codable>(_ route: String, credentials: ClientCredentials? = nil, respondWith: @escaping CodableResultClosure<O>) {
        let credentials = (credentials ?? defaultCredentials)
        let url = baseURL.appendingPathComponent(route)
        let request = RestRequest(url: url.absoluteString, containsSelfSignedCert: self.containsSelfSignedCert, clientCertificate: self.clientCertificate)
        request.headerParameters = credentials?.getHeaders() ?? [:]
        request.acceptType = mediaType
        request.handle(decoder: decoder, respondWith)
    }

    /// Retrieves data from a designated route with an Identifier.
    ///
    /// ### Usage Example: ###
    /// ````
    /// struct User: Codable {
    ///     ...
    /// }
    ///
    /// let client = KituraKit.default
    /// let idOfUserToRetrieve: Int = ...
    /// client.get("/", identifier: idOfUserToRetrieve) { (returnedItem: User?, error: Error?) -> Void in
    ///     print(returnedItem)
    /// }
    /// ````
    /// * This declaration of get retrieves single items. There is another declaration for all item retrieval.
    /// - Parameter route: The custom route KituraKit points to during REST requests.
    /// - Parameter identifier: The custom Identifier object that is searched for.
    public func get<O: Codable>(_ route: String, identifier: Identifier, credentials: ClientCredentials? = nil, respondWith: @escaping CodableResultClosure<O>) {
        let credentials = (credentials ?? defaultCredentials)
        let url = baseURL.appendingPathComponent(route).appendingPathComponent(identifier.value)
        let request = RestRequest(url: url.absoluteString, containsSelfSignedCert: self.containsSelfSignedCert, clientCertificate: self.clientCertificate)
        request.headerParameters = credentials?.getHeaders() ?? [:]
        request.acceptType = mediaType
        request.handle(decoder: decoder, respondWith)
    }

    /// Sends data to a designated route.
    ///
    /// ### Usage Example: ###
    /// ````
    /// struct User: Codable {
    ///     ...
    /// }
    ///
    /// let client = KituraKit.default
    /// let userToSend: User = ...
    /// client.post("/", data: userToSend) { (returnedItem: User?, error: Error?) -> Void in
    ///     print(returnedItem)
    /// }
    /// ````
    /// - Parameter route: The custom route KituraKit points to during REST requests.
    /// - Parameter data: The custom Codable object passed in to be sent.
    public func post<I: Codable, O: Codable>(_ route: String, data: I, credentials: ClientCredentials? = nil, respondWith: @escaping CodableResultClosure<O>) {
        let credentials = (credentials ?? defaultCredentials)
        let url = baseURL.appendingPathComponent(route)
        let encoded = try? encoder.encode(data)
        let request = RestRequest(method: .post, url: url.absoluteString, containsSelfSignedCert: self.containsSelfSignedCert, clientCertificate: self.clientCertificate)
        request.messageBody = encoded
        request.headerParameters = credentials?.getHeaders() ?? [:]
        request.acceptType = mediaType
        request.contentType = mediaType
        request.handle(decoder: decoder, respondWith)
    }

    /// Sends data to a designated route, allowing for the route to respond with an additional Identifier.
    ///
    /// ### Usage Example: ###
    /// ````
    /// struct User: Codable {
    ///     ...
    /// }
    ///
    /// let client = KituraKit.default
    /// let userToSend: User = ...
    /// client.post("/", data: userToSend) { (id: Int?, returnedItem: User?, error: Error?) -> Void in
    ///     print("\(id): \(returnedItem)")
    /// }
    /// ````
    /// - Parameter route: The custom route KituraKit points to during REST requests.
    /// - Parameter data: The custom Codable object passed in to be sent.
    public func post<I: Codable, Id: Identifier, O: Codable>(_ route: String, data: I, credentials: ClientCredentials? = nil, respondWith: @escaping IdentifierCodableResultClosure<Id, O>) {
        let credentials = (credentials ?? defaultCredentials)
        let url = baseURL.appendingPathComponent(route)
        let encoded = try? encoder.encode(data)
        let request = RestRequest(method: .post, url: url.absoluteString, containsSelfSignedCert: self.containsSelfSignedCert, clientCertificate: self.clientCertificate)
        request.messageBody = encoded
        request.headerParameters = credentials?.getHeaders() ?? [:]
        request.acceptType = mediaType
        request.contentType = mediaType
        request.responseData { response in
            switch response.result {
            case .success(let data):
                guard let item: O = try? self.decoder.decode(O.self, from: data),
                      let locationHeader = response.response?.allHeaderFields["Location"] as? String,
                      let id = try? Id.init(value: locationHeader)
                else {
                    respondWith(nil, nil, RequestError.clientDeserializationError)
                    return
                }
                respondWith(id, item, nil)
            case .failure(let error):
                Log.error("POST failure: \(error)")
                respondWith(nil, nil, constructRequestError(from: error, data: response.data))
            }
        }
    }

    /// Updates data for a designated route using an Identifier.
    ///
    /// ### Usage Example: ###
    /// ````
    /// struct User: Codable {
    ///     ...
    /// }
    ///
    /// let client = KituraKit.default
    /// let idOfUserToUpdate: Int = ...
    /// let userToSend: User = ...
    /// client.put("/", identifier: idOfUserToUpdate, data: userToSend) { (returnedItem: User?, error: Error?) -> Void in
    ///     print(returnedItem)
    /// }
    /// ````
    /// * This declaration uses the put method to update data.
    /// - Parameter route: The custom route KituraKit points to during REST requests.
    /// - Parameter identifier: The custom Identifier object that is searched for.
    /// - Parameter data: The custom Codable object passed in to be sent.
    public func put<I: Codable, O: Codable>(_ route: String, identifier: Identifier, data: I, credentials: ClientCredentials? = nil, respondWith: @escaping CodableResultClosure<O>) {
        let credentials = (credentials ?? defaultCredentials)
        let url = baseURL.appendingPathComponent(route).appendingPathComponent(identifier.value)
        let encoded = try? encoder.encode(data)
        let request = RestRequest(method: .put, url: url.absoluteString, containsSelfSignedCert: self.containsSelfSignedCert, clientCertificate: self.clientCertificate)
        request.messageBody = encoded
        request.headerParameters = credentials?.getHeaders() ?? [:]
        request.acceptType = mediaType
        request.contentType = mediaType
        request.handle(decoder: decoder, respondWith)
    }

    /// Updates data for a designated route using an Identifier.
    ///
    /// ### Usage Example: ###
    /// ````
    /// struct User: Codable {
    ///     let name: String
    ///     let address: String
    ///     ...
    /// }
    /// struct OptionalUser: Codable {
    ///     let name: String?
    ///     let address: String?
    ///     ...
    /// }
    ///
    /// let client = KituraKit.default
    /// let idOfUserToUpdate: Int = ...
    /// let userUpdates = OptionalUser(name: "New Name", address: nil, ...)
    /// client.patch("/", identifier: idOfUserToUpdate, data: userUpdates) { (returnedItem: User?, error: Error?) -> Void in
    ///     print(returnedItem)
    /// }
    /// ````
    /// * This declaration uses the patch method to update data.
    /// - Parameter route: The custom route KituraKit points to during REST requests.
    /// - Parameter identifier: The custom Identifier object that is searched for.
    public func patch<I: Codable, O: Codable>(_ route: String, identifier: Identifier, data: I, credentials: ClientCredentials? = nil, respondWith: @escaping CodableResultClosure<O>) {
        let credentials = (credentials ?? defaultCredentials)
        let url = baseURL.appendingPathComponent(route).appendingPathComponent(identifier.value)
        let encoded = try? encoder.encode(data)
        let request = RestRequest(method: .patch, url: url.absoluteString, containsSelfSignedCert: self.containsSelfSignedCert, clientCertificate: self.clientCertificate)
        request.messageBody = encoded
        request.headerParameters = credentials?.getHeaders() ?? [:]
        request.acceptType = mediaType
        request.contentType = mediaType
        request.handle(decoder: decoder, respondWith)
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
    public func delete(_ route: String, credentials: ClientCredentials? = nil, respondWith: @escaping ResultClosure) {
        let credentials = (credentials ?? defaultCredentials)
        let url = baseURL.appendingPathComponent(route)
        let request = RestRequest(method: .delete, url: url.absoluteString, containsSelfSignedCert: self.containsSelfSignedCert, clientCertificate: self.clientCertificate)
        request.headerParameters = credentials?.getHeaders() ?? [:]
        request.acceptType = mediaType
        request.contentType = mediaType
        request.handleDelete(respondWith)
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
    public func delete(_ route: String, identifier: Identifier, credentials: ClientCredentials? = nil, respondWith: @escaping ResultClosure) {
        let credentials = (credentials ?? defaultCredentials)
        let url = baseURL.appendingPathComponent(route).appendingPathComponent(identifier.value)
        let request = RestRequest(method: .delete, url: url.absoluteString, containsSelfSignedCert: self.containsSelfSignedCert, clientCertificate: self.clientCertificate)
        request.headerParameters = credentials?.getHeaders() ?? [:]
        request.acceptType = mediaType
        request.contentType = mediaType
        request.handleDelete(respondWith)
    }

    // HTTP verb/action methods with query parameter support

    ///
    /// Retrieves data at a designated route using a the specified Query Parameters.
    ///
    /// ### Usage Example: ###
    /// ````
    /// struct MyQuery: QueryParams {
    ///    let name: String
    ///  }
    ///
    /// let myQuery = MyQuery(name: "Michael")
    /// let client = KituraKit.default
    ///
    /// client.get("/users", query: myQuery) { (returnedArray: [O]?, error: Error?) -> Void in
    ///     print("Successfully returned users with name 'Michael'")
    ///     print(returnedArray)
    /// }
    /// ````
    /// - Parameter route: The custom route KituraKit points to during REST requests.
    /// - Parameter queryParams: The QueryParam structure containing the route's query parameters
    public func get<O: Codable, Q: QueryParams>(_ route: String, query: Q, credentials: ClientCredentials? = nil, respondWith: @escaping CodableArrayResultClosure<O>) {
        let credentials = (credentials ?? defaultCredentials)
        guard let queryItems: [URLQueryItem] = try? QueryEncoder().encode(query) else {
            respondWith(nil, .clientSerializationError)
            return
        }
        let request = RestRequest(method: .get, url: baseURL.appendingPathComponent(route).absoluteString, containsSelfSignedCert: self.containsSelfSignedCert, clientCertificate: self.clientCertificate)
        request.headerParameters = credentials?.getHeaders() ?? [:]
        request.acceptType = mediaType
        request.contentType = mediaType
        request.handle(decoder: decoder, respondWith, queryItems: queryItems)
    }

    /// Deletes data at a designated route using a the specified Query Parameters.
    ///
    /// ### Usage Example: ###
    /// ````
    /// struct MyQuery: QueryParams {
    ///    let name: String
    ///  }
    ///
    /// let myQuery = MyQuery(name: "Michael")
    /// let client = KituraKit.default
    ///
    /// client.delete("/users", query: myQuery) { error in
    ///     print("Successfully deleted users with name 'Michael'")
    /// }
    /// ````
    /// * This declaration of delete deletes multiple items. There is another declaration for a singular deletion and another for all item deletion.
    /// - Parameter route: The custom route KituraKit points to during REST requests.
    /// - Parameter queryParams: The QueryParam structure containing the route's query parameters
    public func delete<Q: QueryParams>(_ route: String, query: Q, credentials: ClientCredentials? = nil, respondWith: @escaping ResultClosure) {
        let credentials = (credentials ?? defaultCredentials)
        guard let queryItems: [URLQueryItem] = try? QueryEncoder().encode(query) else {
            respondWith(.clientSerializationError)
            return
        }
        let request = RestRequest(method: .delete, url: baseURL.appendingPathComponent(route).absoluteString, containsSelfSignedCert: self.containsSelfSignedCert, clientCertificate: self.clientCertificate)
        request.headerParameters = credentials?.getHeaders() ?? [:]
        request.acceptType = mediaType
        request.contentType = mediaType
        request.handleDelete(respondWith, queryItems: queryItems)
    }
}

/// RestRequest Codable Handler Extension
extension RestRequest {

    /// Helper method to handle the given request for CodableArrayResultClosures and CodableResultClosures
    fileprivate func handle<O: Codable>(decoder: BodyDecoder, _ respondWith: @escaping (O?, RequestError?) -> (), queryItems: [URLQueryItem]? = nil) {
        self.responseData(queryItems: queryItems) { response in
            switch response.result {
            case .success(let data) :
                self.defaultCodableHandler(decoder: decoder, data, respondWith: respondWith)
            case .failure(let error):
                self.defaultErrorHandler(error, data: response.data, respondWith: respondWith)
            }
        }
    }

    /// Helper method to handle the given delete request
    fileprivate func handleDelete(_ respondWith: @escaping (RequestError?) -> (), queryItems: [URLQueryItem]? = nil) {
        self.responseData(queryItems: queryItems) { response in
            switch response.result {
            case .success:
                respondWith(nil)
            case .failure(let error):
                Log.error("DELETE failure: \(error)")
                respondWith(constructRequestError(from: error, data: response.data))
            }
        }
    }

    /// Default success response handler for CodableArrayResultClosures and CodableResultClosures
    private func defaultCodableHandler<O: Codable>(decoder: BodyDecoder, _ data: Data, respondWith: (O?, RequestError?) -> ()) {
        guard let items: O = try? decoder.decode(O.self, from: data) else {
            respondWith(nil, .clientDeserializationError)
            return
        }
        respondWith(items, nil)
    }

    /// Default failure response handler for CodableArrayResultClosures and CodableResultClosures
    private func defaultErrorHandler<O: Codable>(_ error: Error, data: Data?, respondWith: (O?, RequestError?) -> ()) {
        respondWith(nil, constructRequestError(from: error, data: data))
    }
}

// Convert an Error to a RequestError, mapping HTTP error codes over if given a
// SwiftyRequest.RestError. Decorate the RequestError with Data if provided
fileprivate func constructRequestError(from error: Error, data: Data?) -> RequestError {
    var requestError = RequestError.clientConnectionError
    if let restError = error as? RestError {
        requestError = RequestError(restError: restError)
    }
    if let data = data {
        do {
            // TODO: Check Content-Type for format, assuming JSON for now
            requestError = try RequestError(requestError, bodyData: data, format: .json)
        } catch {
            // Do nothing, format not supported
        }
    }
    return requestError
}

/// Checks for mistyped URLs for the client route path.
///
/// ### Usage Example: ###
/// ````
/// let checkedUrl = checkMistypedURL(inputURL: baseURL)
/// ````
/// - Parameter inputURL: The string that is checked for mistypes.
private func checkMistypedProtocol(inputURL: String) -> String {
    let mistypes = ["http:/","http:","http","htp://","ttp://","htttp://","htpp://","http//","htt://","http:://","http:///","httpp://","hhttp://","htt:"]
    if String(inputURL.prefix(7)).lowercased() == "http://" || String(inputURL.prefix(8)).lowercased() == "https://"{
        if String(inputURL.prefix(8)).lowercased() != "http:///" {
            return inputURL
        }
    }
    //search the first 8 - 4 charecters for matching mistypes and replace with http://
    for i in (4...8).reversed() {
        for item in mistypes{
            if String(inputURL.prefix(i)).lowercased() == item {
                let processedUrl = inputURL.dropFirst(i)
                return "http://\(processedUrl)"
            }
        }
    }
    //if no matching mistypes just add http:// to the front
    return "http://\(inputURL)"
}
