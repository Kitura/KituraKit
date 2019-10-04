/*
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
 * See the License for the specific langua›ge governing permissions and
 * limitations under the License.
 */

import Foundation
import KituraContracts
import SwiftyRequest

/// An extension to Kitura RequestErrors with additional error codes specifically for the client.
extension RequestError {

    /// An initializer to set up the client error codes.
    /// - Parameter clientErrorCode: The custom error code for the client.
    public init(clientErrorCode: Int, clientErrorDescription: String, underlyingError: Error? = nil) {
        if let error = underlyingError {
            self.init(rawValue: clientErrorCode, reason: clientErrorDescription + " - underlying error: \(error)")
        } else {
            self.init(rawValue: clientErrorCode, reason: clientErrorDescription)
        }
    }

    /// An HTTP 600 unknown error
    public static let clientErrorUnknown = RequestError(clientErrorCode: 600, clientErrorDescription: "An unknown error occurred")
    
    /// An HTTP 601 connection error
    public static let clientConnectionError = RequestError(clientErrorCode: 601, clientErrorDescription: "A connection error occurred, cannot connect to the server. Please ensure that the server is started and running, with the correct port and URL ('ToDoServer' if using the sample app).")
    
    /// An HTTP 602 no data error
    public static let clientNoData = RequestError(clientErrorCode: 602, clientErrorDescription: "A no data error occurred.")
    
    /// An HTTP 603 serialization error
    public static let clientSerializationError = RequestError.clientSerializationError(underlyingError: nil)
    
    /// An HTTP 604 deserialization error
    public static let clientDeserializationError = RequestError.clientDecodingError(underlyingError: nil)
    
    /// An HTTP 605 encoding error
    public static let clientEncodingError = RequestError.clientEncodingError(underlyingError: nil)
    
    /// An HTTP 606 file manager error
    public static let clientFileManagerError = RequestError(clientErrorCode: 606, clientErrorDescription: "A file manager error occurred. Please ensure that the file exists, and correct permissions to the file manager are present for the user.")
    
    /// An HTTP 607 invalid file error
    public static let clientInvalidFile = RequestError(clientErrorCode: 607, clientErrorDescription: "An invalid file error occurred.")
    
    /// An HTTP 608 invalid substitution error
    public static let clientInvalidSubstitution = RequestError(clientErrorCode: 608, clientErrorDescription: "An invalid substitution error occurred.")

    /// An HTTP 609 encoding error
    public static let clientDecodingError = RequestError.clientDecodingError(underlyingError: nil)

    static func clientDecodingError(underlyingError: Error?) -> RequestError {
        return RequestError(clientErrorCode: 609, clientErrorDescription: "A decoding error occurred.", underlyingError: underlyingError)
    }

    static func clientEncodingError(underlyingError: Error?) -> RequestError {
        return RequestError(clientErrorCode: 605, clientErrorDescription: "An encoding error occurred.", underlyingError: underlyingError)
    }

    static func clientSerializationError(underlyingError: Error?) -> RequestError {
        return RequestError(clientErrorCode: 603, clientErrorDescription: "A serialization error occurred.", underlyingError: underlyingError)
    }
}

/// An extension to Kitura RequestErrors with additional error codes specifically for the client.
extension RequestError {

    static func makeRequestError(_ base: RequestError, underlyingError: RestError) -> RequestError {
        return RequestError(clientErrorCode: base.rawValue, clientErrorDescription: base.reason, underlyingError: underlyingError)
    }

    /// An initializer to switch between different error types.
    /// - Parameter restError: The custom error type for the client.
    public init(restError: RestError) {
        switch restError {
        case .noData: self = RequestError.makeRequestError(.clientNoData, underlyingError: restError)
        case .serializationError: self = RequestError.makeRequestError(.clientSerializationError, underlyingError: restError)
        case .encodingError: self = RequestError.makeRequestError(.clientEncodingError, underlyingError: restError)
        case .decodingError: self = RequestError.makeRequestError(.clientDecodingError, underlyingError: restError)
        case .fileManagerError: self = RequestError.makeRequestError(.clientFileManagerError, underlyingError: restError)
        case .invalidFile: self = RequestError.makeRequestError(.clientInvalidFile, underlyingError: restError)
        case .invalidSubstitution: self = RequestError.makeRequestError(.clientInvalidSubstitution, underlyingError: restError)
        case .invalidURL: fallthrough       // Will not occur: Client can only be initialized with a valid URL
        case .downloadError: fallthrough    // Will not occur: API is not used by KituraKit
        case .errorStatusCode: fallthrough
        default:
            // All other cases:
            if let response = restError.response {
                self = RequestError(httpCode: Int(response.status.code))
            } else {
                self = RequestError(rawValue: 0, reason: "Error: No response was received by the client")
            }
        }
    }
}
