/**
* Copyright IBM Corporation 2017, 2018
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

/** An Error representing a failure within the CircuitBreaker call

    ** BreakerError is intendend to be extended to describe command context errors **

    ### Usage Example: ###
    ````
    extension BreakerError {
      public static let URLEncodingError = BreakerError(reason: "URL Could Not Be Found")
      public static let responseError = BreakerError(reason: "Invalid Response Error")
    }

    func myContextFunction(invocation: Invocation<(String), Void, String>) {
      guard let url = URL(string: "http://mysever.net/path/\(invocation.commandArgs)") else {
        invocation.notifyFailure(error: BreakerError.URLEncodingError)
      }

      URLSession.shared.dataTask(with: URLRequest(url: url)) { result, res, err in
        guard let result = result else {
          invocation.notifyFailure(error: BreakerError.responseError)
          return
        }

        invocation.notifySuccess()
      }.resume()
    }
  ````
*/
public struct BreakerError: Error {

  /// Unique key for a breaker error
  public let key: String

  /// String descibing the error
  public let reason: String?

  /// Breaker Error Initializer
  ///
  /// - Parameters
  ///   - key: Optional string key for the error
  ///   - reason: Optional string describing the error
  public init(key: String? = nil, reason: String? = nil) {
      self.key = key ?? UUID().uuidString
      self.reason = reason
  }

  /// Convenience Breaker Error Initializer
  ///
  /// - Parameters
  ///   - reason: Optional string describing the error
  public init(reason: String? = nil) {
    self.init(key: nil, reason: reason)
  }

  /// MARK - Build-in Errors

  /// Command Timeout Error
  public static let timeout = BreakerError(key: "Timeout", reason: "A timeout occurred")

  /// Circuit is open - error denoting failing fast state
  public static let fastFail = BreakerError(key: "Fast Fail", reason: "An error occurred in an open state. Failing fast.")
}

/// Protocol Conformance Extension
extension BreakerError: CustomStringConvertible, Equatable {

  /// A textual description of the BreakerError instance containing the reason.
  public var description: String {
    return "BreakerError : \(reason ?? "There was an error.")"
  }

  /// Indicates whether two breaker errors are the same.
  public static func ==(lhs: BreakerError, rhs: BreakerError) -> Bool {
    return lhs.key == rhs.key
  }
}
