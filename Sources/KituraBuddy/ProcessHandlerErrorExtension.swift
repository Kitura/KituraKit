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

extension RequestError {
    
    init(clientErrorCode: Int) {
        self.init(rawValue: clientErrorCode)
    }

    public static var clientErrorUnknown = RequestError(clientErrorCode: 600)
    public static var clientConnectionError = RequestError(clientErrorCode: 601)
    public static var clientNoData = RequestError(clientErrorCode: 602)
    public static var clientSerializationError = RequestError(clientErrorCode: 603)
    public static var clientDeserializationError = RequestError(clientErrorCode: 604)
    public static var clientEncodingError = RequestError(clientErrorCode: 605)
    public static var clientFileManagerError = RequestError(clientErrorCode: 606)
    public static var clientInvalidFile = RequestError(clientErrorCode: 607)
    public static var clientInvalidSubstitution = RequestError(clientErrorCode: 608)
}

extension RequestError {
    init(restError: RestError) {
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
