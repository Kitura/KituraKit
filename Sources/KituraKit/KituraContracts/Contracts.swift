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

// MARK

/**
 An error representing a failed request.
 This definition is intended to be used by both the client side (eg KituraKit)
 and server side (eg Kitura) of the request (typically a HTTP REST request).

 ### Usage Example: ###
 ````
 router.get("/users") { (id: Int, respondWith: (User?, RequestError?) -> Void) in
     ...
     respondWith(nil, RequestError.notFound)
     ...
 }
 ````
 In this example the `RequestError` is used in a Kitura server Codable route handler to
 indicate the request has failed because the requested record was not found.
 */
public struct RequestError: RawRepresentable, Equatable, Hashable, Comparable, Error, CustomStringConvertible {
    public typealias RawValue = Int

    /// Representation of the error body
    /// May be a type-erased Codable object or a Data (in a particular format)
    public enum ErrorBody {
        case codable(Codable)
        case data(Data, BodyFormat)
    }

    // MARK: Creating a RequestError from a numeric code

    /// Creates an error representing the given error code.
    public init(rawValue: Int) {
        self.rawValue = rawValue
        self.reason = "error_\(rawValue)"
    }

    /// Creates an error representing the given error code and reason string.
    public init(rawValue: Int, reason: String) {
        self.rawValue = rawValue
        self.reason = reason
    }

    /// Creates an error representing the given base error, with a custom
    /// response body given as a Codable
    public init<Body: Codable>(_ base: RequestError, body: Body) {
        self.rawValue = base.rawValue
        self.reason = base.reason
        self.body = .codable(body)
        self.bodyDataEncoder = { format in
            switch format {
                case .json: return try JSONEncoder().encode(body)
                default: throw UnsupportedBodyFormatError(format)
            }
        }
    }

    /// Creates an error respresenting the given base error, with a custom
    /// response body given as Data and a BodyFormat
    ///
    /// - throws an `UnsupportedBodyFormatError` if the provided `BodyFormat`
    ///          is not supported
    public init(_ base: RequestError, bodyData: Data, format: BodyFormat) throws {
        self.rawValue = base.rawValue
        self.reason = base.reason
        self.body = .data(bodyData, format)
        switch format {
            case .json: break
            default: throw UnsupportedBodyFormatError(format)
        }
    }

    // MARK: Accessing information about the error.

    /// An error code representing the type of error that has occurred.
    /// The range of error codes from 100 up to 599 are reserved for HTTP status codes.
    /// Custom error codes may be used and must not conflict with this range.
    public let rawValue: Int

    /// A human-readable description of the error code.
    public let reason: String

    /**
     Representation of the error body-an object representing further
     details of the failure.

     The value may be:
     - `nil` if there is no body
     - a (type-erased) Codable object if the error was initialized with `init(_:body:)`
     - bytes of data and a signifier of the format in which they are stored (eg: JSON)
       if the error was initialized with `init(_:bodyData:format:)`

     ### Usage example: ###
     ````
     if let errorBody = error.body {
         switch error.body {
            case let .codable(body): ... // body is Codable
            case let .data(bytes, format): ... // bytes is Data, format is BodyFormat
         }
     }
     ````

     - Note: If you need a Codable representation and the body is data, you
             can call the `bodyAs(_:)` function to get the converted value
     */
    public private(set) var body: ErrorBody? = nil

    // A closure used to hide the generic type of the Codable body
    // for later encoding to Data
    private var bodyDataEncoder: ((BodyFormat) throws -> Data)? = nil

    /**
     Returns the Codable error body encoded into bytes in a given format (eg: JSON).

     This function should be used if the RequestError was created using
     `init(_:body:)`, otherwise it will return `nil`.

     - Note: This function is primarily intended for use by the Kitura Router so
             that it can encode and send a custom error body returned from
             a codable route.

     ### Usage Example: ###
     ````
     do {
         if let errorBodyData = try error.encodeBody(.json) {
             ...
         }
     } catch {
         // Handle the failure to encode
     }
     ````
     - parameter `BodyFormat` describes the format that should be used
                 (for example: `BodyFormat.json`)
     - returns the `Data` object or `nil` if there is no body, or if the
               error was not initialized with `init(_:body:)`
     - throws an `EncodingError` if the encoding fails
     - throws an `UnsupportedBodyFormatError` if the provided `BodyFormat`
              is not supported
     */
    public func encodeBody(_ format: BodyFormat) throws -> Data? {
        guard case .codable? = body else { return nil }
        return try bodyDataEncoder?(format)
    }

    /**
     Returns the Data error body as the requested `Codable` type.

     This function should be used if the RequestError was created using
     `init(_:bodyData:format:)`, otherwise it will return `nil`.

     This function throws; you can use `bodyAs(_:)` instead if you want
     to ignore DecodingErrors.

     - Note: This function is primarily intended for use by users of KituraKit
             or similar client-side code that needs to convert a custom error
             response from `Data` to a `Codable` type.

     ### Usage Example: ###
     ```
     do {
         if let errorBody = try error.decodeBody(MyCodableType.self) {
             ...
         }
     } catch {
         // Handle failure to decode
     }
     ```
     - parameter the type of the value to decode from the body data
                 (for example: `MyCodableType.self`)
     - returns the `Codable` object or `nil` if there is no body or if the
               error was not initialized with `init(_:bodyData:format:)`
     - throws a `DecodingError` if decoding fails
     */
    public func decodeBody<Body: Codable>(_ type: Body.Type) throws -> Body? {
        guard case let .data(bodyData, format)? = body else { return nil }
        switch format {
            case .json: return try JSONDecoder().decode(type, from: bodyData)
            default: throw UnsupportedBodyFormatError(format)
        }
    }

    /**
     Returns the Data error body as the requested `Codable` type.

     This function should be used if the RequestError was created using
     `init(_:bodyData:format:)`, otherwise it will return `nil`.

     This function ignores DecodingErrors, and returns `nil` if decoding
     fails. If you want DecodingErrors to be thrown, use `decodeBody(_:)`
     instead.

     - Note: This function is primarily intended for use by users of KituraKit
             or similar client-side code that needs to convert a custom error
             response from `Data` to a `Codable` type.

     ### Usage Example: ###
     ```
     if let errorBody = error.bodyAs(MyCodableType.self) {
         ...
     }
     ```
     - parameter the type of the value to decode from the body data
                 (for example: `MyCodableType.self`)
     - returns the `Codable` object or `nil` if there is no body, or if the
               error was not initialized with `init(_:bodyData:format:)`, or
               if decoding fails
     */
    public func bodyAs<Body: Codable>(_ type: Body.Type) -> Body? {
        return (try? decodeBody(type)) ?? nil
    }

    // MARK: Comparing RequestErrors

    /// Returns a Boolean value indicating whether the value of the first argument is less than that of the second argument.
    public static func < (lhs: RequestError, rhs: RequestError) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }

    /// Indicates whether two URLs are the same.
    public static func == (lhs: RequestError, rhs: RequestError) -> Bool {
        return (lhs.rawValue == rhs.rawValue && lhs.reason == rhs.reason)
    }

    // MARK: Describing a RequestError

    /// A textual description of the RequestError instance containing the error code and reason.
    public var description: String {
        return "\(rawValue) : \(reason)"
    }

    /// The computed hash value for the RequestError instance.
    public var hashValue: Int {
        let str = reason + String(rawValue)
        return str.hashValue
    }
}

/**
 Extends `RequestError` to provide HTTP specific error code and reason values.
 */
public extension RequestError {

    /// The HTTP status code for the error.
    /// This value should be a valid HTTP status code if inside the range 100 to 599,
    /// however, it may take a value outside that range when representing other types
    /// of error.
    public var httpCode: Int {
        return rawValue
    }

    /// Creates an error representing a HTTP status code.
    /// - Parameter httpCode: a standard HTTP status code
    public init(httpCode: Int) {
        self.rawValue = httpCode
        self.reason = RequestError.reason(forHTTPCode: httpCode)
    }

    // MARK: Accessing constants representing HTTP status codes
    /// HTTP code 100 - Continue
    public static let `continue` = RequestError(httpCode: 100)
    /// HTTP code 101 - Switching Protocols
    public static let switchingProtocols = RequestError(httpCode: 101)
    /// HTTP code 200 - OK
    public static let ok = RequestError(httpCode: 200)
    /// HTTP code 201 - Created
    public static let created = RequestError(httpCode: 201)
    /// HTTP code 202 - Accepted
    public static let accepted = RequestError(httpCode: 202)
    /// HTTP code 203 - Non Authoritative Information
    public static let nonAuthoritativeInformation = RequestError(httpCode: 203)
    /// HTTP code 204 - No Content
    public static let noContent = RequestError(httpCode: 204)
    /// HTTP code 205 - Reset Content
    public static let resetContent = RequestError(httpCode: 205)
    /// HTTP code 206 - Partial Content
    public static let partialContent = RequestError(httpCode: 206)
    /// HTTP code 207 - Multi Status
    public static let multiStatus = RequestError(httpCode: 207)
    /// HTTP code 208 - Already Reported
    public static let alreadyReported = RequestError(httpCode: 208)
    /// HTTP code 226 - IM Used
    public static let imUsed = RequestError(httpCode: 226)
    /// HTTP code 300 - Multiple Choices
    public static let multipleChoices = RequestError(httpCode: 300)
    /// HTTP code 301 - Moved Permanently
    public static let movedPermanently = RequestError(httpCode: 301)
    /// HTTP code 302 - Found
    public static let found = RequestError(httpCode: 302)
    /// HTTP code 303 - See Other
    public static let seeOther = RequestError(httpCode: 303)
    /// HTTP code 304 - Not Modified
    public static let notModified = RequestError(httpCode: 304)
    /// HTTP code 305 - Use Proxy
    public static let useProxy = RequestError(httpCode: 305)
    /// HTTP code 307 - Temporary Redirect
    public static let temporaryRedirect = RequestError(httpCode: 307)
    /// HTTP code 308 - Permanent Redirect
    public static let permanentRedirect = RequestError(httpCode: 308)
    /// HTTP code 400 - Bad Request
    public static let badRequest = RequestError(httpCode: 400)
    /// HTTP code 401 - Unauthorized
    public static let unauthorized = RequestError(httpCode: 401)
    /// HTTP code 402 - Payment Required
    public static let paymentRequired = RequestError(httpCode: 402)
    /// HTTP code 403 - Forbidden
    public static let forbidden = RequestError(httpCode: 403)
    /// HTTP code 404 - Not Found
    public static let notFound = RequestError(httpCode: 404)
    /// HTTP code 405 - Method Not Allowed
    public static let methodNotAllowed = RequestError(httpCode: 405)
    /// HTTP code 406 - Not Acceptable
    public static let notAcceptable = RequestError(httpCode: 406)
    /// HTTP code 407 - Proxy Authentication Required
    public static let proxyAuthenticationRequired = RequestError(httpCode: 407)
    /// HTTP code 408 - Request Timeout
    public static let requestTimeout = RequestError(httpCode: 408)
    /// HTTP code 409 - Conflict
    public static let conflict = RequestError(httpCode: 409)
    /// HTTP code 410 - Gone
    public static let gone = RequestError(httpCode: 410)
    /// HTTP code 411 - Length Required
    public static let lengthRequired = RequestError(httpCode: 411)
    /// HTTP code 412 - Precondition Failed
    public static let preconditionFailed = RequestError(httpCode: 412)
    /// HTTP code 413 - Payload Too Large
    public static let payloadTooLarge = RequestError(httpCode: 413)
    /// HTTP code 414 - URI Too Long
    public static let uriTooLong = RequestError(httpCode: 414)
    /// HTTP code 415 - Unsupported Media Type
    public static let unsupportedMediaType = RequestError(httpCode: 415)
    /// HTTP code 416 - Range Not Satisfiable
    public static let rangeNotSatisfiable = RequestError(httpCode: 416)
    /// HTTP code 417 - Expectation Failed
    public static let expectationFailed = RequestError(httpCode: 417)
    /// HTTP code 421 - Misdirected Request
    public static let misdirectedRequest = RequestError(httpCode: 421)
    /// HTTP code 422 - Unprocessable Entity
    public static let unprocessableEntity = RequestError(httpCode: 422)
    /// HTTP code 423 - Locked
    public static let locked = RequestError(httpCode: 423)
    /// HTTP code 424 - Failed Dependency
    public static let failedDependency = RequestError(httpCode: 424)
    /// HTTP code 426 - Upgrade Required
    public static let upgradeRequired = RequestError(httpCode: 426)
    /// HTTP code 428 - Precondition Required
    public static let preconditionRequired = RequestError(httpCode: 428)
    /// HTTP code 429 - Too Many Requests
    public static let tooManyRequests = RequestError(httpCode: 429)
    /// HTTP code 431 - Request Header Fields Too Large
    public static let requestHeaderFieldsTooLarge = RequestError(httpCode: 431)
    /// HTTP code 451 - Unavailable For Legal Reasons
    public static let unavailableForLegalReasons = RequestError(httpCode: 451)
    /// HTTP code 500 - Internal Server Error
    public static let internalServerError = RequestError(httpCode: 500)
    /// HTTP code 501 - Not Implemented
    public static let notImplemented = RequestError(httpCode: 501)
    /// HTTP code 502 - Bad Gateway
    public static let badGateway = RequestError(httpCode: 502)
    /// HTTP code 503 - Service Unavailable
    public static let serviceUnavailable = RequestError(httpCode: 503)
    /// HTTP code 504 - Gateway Timeout
    public static let gatewayTimeout = RequestError(httpCode: 504)
    /// HTTP code 505 - HTTP Version Not Supported
    public static let httpVersionNotSupported = RequestError(httpCode: 505)
    /// HTTP code 506 - Variant Also Negotiates
    public static let variantAlsoNegotiates = RequestError(httpCode: 506)
    /// HTTP code 507 - Insufficient Storage
    public static let insufficientStorage = RequestError(httpCode: 507)
    /// HTTP code 508 - Loop Detected
    public static let loopDetected = RequestError(httpCode: 508)
    /// HTTP code 510 - Not Extended
    public static let notExtended = RequestError(httpCode: 510)
    /// HTTP code 511 - Network Authentication Required
    public static let networkAuthenticationRequired = RequestError(httpCode: 511)

    private static func reason(forHTTPCode code: Int) -> String {
        switch code {
            case 100: return "Continue"
            case 101: return "Switching Protocols"
            case 200: return "OK"
            case 201: return "Created"
            case 202: return "Accepted"
            case 203: return "Non-Authoritative Information"
            case 204: return "No Content"
            case 205: return "Reset Content"
            case 206: return "Partial Content"
            case 207: return "Multi-Status"
            case 208: return "Already Reported"
            case 226: return "IM Used"
            case 300: return "Multiple Choices"
            case 301: return "Moved Permanently"
            case 302: return "Found"
            case 303: return "See Other"
            case 304: return "Not Modified"
            case 305: return "Use Proxy"
            case 307: return "Temporary Redirect"
            case 308: return "Permanent Redirect"
            case 400: return "Bad Request"
            case 401: return "Unauthorized"
            case 402: return "Payment Required"
            case 403: return "Forbidden"
            case 404: return "Not Found"
            case 405: return "Method Not Allowed"
            case 406: return "Not Acceptable"
            case 407: return "Proxy Authentication Required"
            case 408: return "Request Timeout"
            case 409: return "Conflict"
            case 410: return "Gone"
            case 411: return "Length Required"
            case 412: return "Precondition Failed"
            case 413: return "Payload Too Large"
            case 414: return "URI Too Long"
            case 415: return "Unsupported Media Type"
            case 416: return "Range Not Satisfiable"
            case 417: return "Expectation Failed"
            case 421: return "Misdirected Request"
            case 422: return "Unprocessable Entity"
            case 423: return "Locked"
            case 424: return "Failed Dependency"
            case 426: return "Upgrade Required"
            case 428: return "Precondition Required"
            case 429: return "Too Many Requests"
            case 431: return "Request Header Fields Too Large"
            case 451: return "Unavailable For Legal Reasons"
            case 500: return "Internal Server Error"
            case 501: return "Not Implemented"
            case 502: return "Bad Gateway"
            case 503: return "Service Unavailable"
            case 504: return "Gateway Timeout"
            case 505: return "HTTP Version Not Supported"
            case 506: return "Variant Also Negotiates"
            case 507: return "Insufficient Storage"
            case 508: return "Loop Detected"
            case 510: return "Not Extended"
            case 511: return "Network Authentication Required"
            default: return "http_\(code)"
        }
    }
}

/**
 An identifier for a query parameter object
 */
public protocol QueryParams: Codable {}

/**
 An error representing a failure to create an `Identifier`.
 */
public enum IdentifierError: Error {
    /// Represents a failure to create an `Identifier` from a given `String` representation.
    case invalidValue
}

/**
 An identifier for an entity with a string representation.
 */
public protocol Identifier {
    /// Creates an identifier from a given string value.
    /// - Throws: An IdentifierError.invalidValue if the given string is not a valid representation.
    init(value: String) throws

    /// The string representation of the identifier.
    var value: String { get }
}

/**
 Extends `String` to comply to the `Identifier` protocol.
 */
extension String: Identifier {
    /// Creates a string identifier from a given string value.
    public init(value: String) {
        self.init(value)
    }

    /// The string representation of the identifier.
    public var value: String {
        return self
    }
}

/**
 Extends `Int` to comply to the `Identifier` protocol.
 */
extension Int: Identifier {
    /// Creates an integer identifier from a given string representation.
    /// - Throws: An `IdentifierError.invalidValue` if the given string cannot be converted to an integer.
    public init(value: String) throws {
        if let id = Int(value) {
            self = id
        } else {
            throw IdentifierError.invalidValue
        }
    }

    /// The string representation of the identifier.
    public var value: String {
        return String(describing: self)
    }
}

//public protocol Persistable: Codable {
//    // Related types
//    associatedtype Id: Identifier
//
//    // Create
//    static func create(model: Self, respondWith: @escaping (Self?, RequestError?) -> Void)
//    // Read
//    static func read(id: Id, respondWith: @escaping (Self?, RequestError?) -> Void)
//    // Read all
//    static func read(respondWith: @escaping ([Self]?, RequestError?) -> Void)
//    // Update
//    static func update(id: Id, model: Self, respondWith: @escaping (Self?, RequestError?) -> Void)
//    // How about returning Identifer instances for the delete operations?
//    // Delete
//    static func delete(id: Id, respondWith: @escaping (RequestError?) -> Void)
//    // Delete all
//    static func delete(respondWith: @escaping (RequestError?) -> Void)
//}
//
//// Provides utility methods for getting the type  and routes for the class
//// conforming to Persistable
//public extension Persistable {
//    // Set up name space based on name of model (e.g. User -> user(s))
//    static var type: String {
//        let kind = String(describing: Swift.type(of: self))
//        return String(kind.characters.dropLast(5))
//    }
//    static var typeLowerCased: String { return "\(type.lowercased())" }
//    static var route: String { return "/\(typeLowerCased)s" }
//}
