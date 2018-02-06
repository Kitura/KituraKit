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
import Dispatch

/// Invocation entity
public class Invocation<A, B> {

  /// Arguments for circuit command
  public let commandArgs: A

  /// Arguments for circuit fallback
  public let fallbackArgs: B

  /// Timeout state of invocation
  private(set) var timedOut: Bool = false

  /// Completion state of invocation
  private(set) var completed: Bool = false

  private let startTime: Date

  private let startExecutionTime = Date()

  // Semaphore to avoid race conditions in the state of the invocation
  private let semaphoreCompleted = DispatchSemaphore(value: 1)

  weak private var breaker: CircuitBreaker<A, B>?

  /// Invocation Initializer
  /// - Parameters:
  ///   - breaker CircuitBreaker Instance
  ///   - commandArgs Arguments for command context
  ///
  public init(startTime: Date, breaker: CircuitBreaker<A, B>, commandArgs: A, fallbackArgs: B) {
    self.breaker = breaker
    self.commandArgs = commandArgs
    self.fallbackArgs = fallbackArgs
    self.startTime = startTime
  }

  /// Marks invocation as having timed out if and only if the execution
  /// of the invocation has not completed yet. In such case, true is returned;
  // otherwise, false.
  public func nofityTimedOut() -> Bool {
    semaphoreCompleted.wait()
    if !self.completed {
      setTimedOut()
      semaphoreCompleted.signal()
      // Revisit Execution versus Total Latency
      // Track latency for timeout in same way as brakes (https://github.com/awolden/brakes/)
      breaker?.breakerStats.trackTotalLatency(latency: Int(Date().timeIntervalSince(startTime)))
      return true
    }
    semaphoreCompleted.signal()
    return false
  }

  /// Marks invocation as having timed out.
  /// This function should be called within the boundaries of a semaphore.
  /// Otherwise, resulting behavior may be unexpected.
  private func setTimedOut() {
    self.timedOut = true
  }

  /// Marks invocation as completed
  /// This function should be called within the boundaries of a semaphore.
  /// Otherwise, resulting behavior may be unexpected.
  private func setCompleted() {
    self.completed = true
  }

  /// Notifies the circuit breaker of success if a timeout has not already been triggered
  public func notifySuccess() {
    semaphoreCompleted.wait()
    if !self.timedOut {
      self.setCompleted()
      semaphoreCompleted.signal()
      breaker?.notifySuccess()
      breaker?.breakerStats.trackTotalLatency(latency: Int(Date().timeIntervalSince(startTime)))
      breaker?.breakerStats.trackExecutionLatency(latency: Int(Date().timeIntervalSince(startTime)))
      return
    }
    semaphoreCompleted.signal()
  }

  /// Notifies the circuit breaker of success if a timeout has not already been triggered
  /// - Parameters:
  ///   - error: The corresponding error msg
  ///
  public func notifyFailure(error: BreakerError) {
    semaphoreCompleted.wait()
    if !self.timedOut {
      // There was an error within the invocated function
      self.setCompleted()
      semaphoreCompleted.signal()
      breaker?.notifyFailure(error: error, fallbackArgs: fallbackArgs)
      breaker?.breakerStats.trackTotalLatency(latency: Int(Date().timeIntervalSince(startTime)))
      breaker?.breakerStats.trackExecutionLatency(latency: Int(Date().timeIntervalSince(startTime)))
      return
    }
    semaphoreCompleted.signal()
  }

}
