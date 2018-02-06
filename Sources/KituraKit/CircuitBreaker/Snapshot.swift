/**
* Copyright IBM Corporation 2017 2018
*
* Licensed under the Apache License Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing software
* distributed under the License is distributed on an "AS IS" BASIS
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
**/

import Foundation

/// Stats Snapshot
public struct Snapshot: Codable {

  /// Tracked Statistics

  /// Name of CircuitBreaker instance
  let name: String

  /// CircuitBreaker instance group
  let group: String?

  /// Current time
  let currentTime: Double

  /// Bool identifying if the circuit is open
  let isCircuitBreakerOpen: Bool

  /// Percentage of responses that threw an error
  let errorPercentage: Double

  /// Number of errored responses
  let errorCount: Int

  /// Number of requests made
  let requestCount: Int

  let rollingCountShortCircuited: Int

  /// Number of successful requests
  let rollingCountSuccess: Int

  /// Number of failed requests
  let rollingCountFailure: Int

  /// Number of timed-out requests
  let rollingCountTimeout: Int

  /// Average execution latency
  let latencyExecute_mean: Int

  /// Execution latency by perentile
  let latencyExecute: [Double: Int]

  /// Average total latency
  let latencyTotal_mean: Int

  /// Total latency by perentile
  let latencyTotal: [Double: Int]

  /// Type of data object
  let type: String = "HystrixCommand"

  // Untracked Stats
  let rollingCountBadRequests: Int = 0
  let rollingCountCollapsedRequests: Int = 0
  let rollingCountExceptionsThrown: Int =  0
  let rollingCountFallbackFailure: Int = 0
  let rollingCountFallbackRejection: Int = 0
  let rollingCountFallbackSuccess: Int = 0
  let rollingCountResponsesFromCache: Int = 0
  let rollingCountSemaphoreRejected: Int = 0
  let rollingCountThreadPoolRejected: Int = 0
  let currentConcurrentExecutionCount: Int = 0
  let propertyValue_circuitBreakerRequestVolumeThreshold: Int = 0 //json.waitThreshold
  let propertyValue_circuitBreakerSleepWindowInMilliseconds: Int = 0 //json.circuitDuration
  let propertyValue_circuitBreakerErrorThresholdPercentage: Int = 0 //json.threshold
  let propertyValue_circuitBreakerForceOpen: Bool = false
  let propertyValue_circuitBreakerForceClosed: Bool = false
  let propertyValue_circuitBreakerEnabled: Bool = true
  let propertyValue_executionIsolationStrategy: String = "THREAD"
  let propertyValue_executionIsolationThreadTimeoutInMilliseconds: Int = 800
  let propertyValue_executionIsolationThreadInterruptOnTimeout: Bool = true
  let propertyValue_executionIsolationThreadPoolKeyOverride: String? = nil
  let propertyValue_executionIsolationSemaphoreMaxConcurrentRequests: Int = 20 //
  let propertyValue_fallbackIsolationSemaphoreMaxConcurrentRequests: Int = 10 //
  let propertyValue_metricsRollingStatisticalWindowInMilliseconds: Int = 10000 //
  let propertyValue_requestCacheEnabled: Bool = false
  let propertyValue_requestLogEnabled: Bool = false
  let reportingHosts: Int = 1

  /// Initializer
  ///
  /// - Parameters:
  ///   - name: CircuitBreaker instance name
  ///   - group: CircuitBreaker group name
  ///   - stats: Stats
  ///   - state: BreakerState
  public init(name: String, group: String? = nil, stats: Stats, state: State) {
    self.name = name
    self.group = group
    self.currentTime = Date().timeIntervalSinceNow
    self.isCircuitBreakerOpen = state == .open
    self.errorPercentage = stats.errorPercentage
    self.errorCount = stats.errorCount
    self.requestCount = stats.totalRequests
    self.rollingCountShortCircuited = stats.rejectedRequests
    self.rollingCountSuccess = stats.successful
    self.rollingCountFailure = stats.failed
    self.rollingCountTimeout = stats.timeouts
    self.latencyExecute_mean = stats.meanExecutionLatency
    self.latencyTotal_mean = stats.meanTotalLatency
    self.latencyExecute = stats.latencyExecute
    self.latencyTotal = stats.latencyTotal
  }
}
