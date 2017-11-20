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

/// An extension to Kitura RequestErrors with additional error codes specifically for the client.
public extension RequestError {

    /// An initializer to set up the client error codes.
    /// - Parameter clientErrorCode: The custom error code for the client.
    init(clientErrorCode: Int) {
        self.init(rawValue: clientErrorCode)
    }

    /// An HTTP 600 unknown error
    public static var clientErrorUnknown = RequestError(clientErrorCode: 600)
    
    /// An HTTP 601 connection error
    public static var clientConnectionError = RequestError(clientErrorCode: 601)
    
    /// An HTTP 602 no data error
    public static var clientNoData = RequestError(clientErrorCode: 602)
    
    /// An HTTP 603 serialization error
    public static var clientSerializationError = RequestError(clientErrorCode: 603)
    
    /// An HTTP 604 deserialization error
    public static var clientDeserializationError = RequestError(clientErrorCode: 604)
    
    /// An HTTP 605 encoding error
    public static var clientEncodingError = RequestError(clientErrorCode: 605)
    
    /// An HTTP 606 file manager error
    public static var clientFileManagerError = RequestError(clientErrorCode: 606)
    
    /// An HTTP 607 invalid file error
    public static var clientInvalidFile = RequestError(clientErrorCode: 607)
    
    /// An HTTP 608 invalid substitution error
    public static var clientInvalidSubstitution = RequestError(clientErrorCode: 608)
}

/// An extension to Kitura RequestErrors with additional error codes specifically for the client.
public extension RequestError {
    
    /// An initializer to switch between different error types.
    /// - Parameter restError: The custom error type for the client.
    public init(restError: RestError) {
        switch restError {
        case .erroredResponseStatus(let code): self = RequestError(httpCode: code)
        case .noData: self = .clientNoData
        case .serializationError: self = .clientSerializationError
        case .encodingError: self = .clientEncodingError
        case .fileManagerError: self = .clientFileManagerError
        case .invalidFile: self = .clientInvalidFile
        case .invalidSubstitution: self = .clientInvalidSubstitution
        }
    }
}
