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

/// Circuit Breaker Stats
public class Stats {

  /// Mark - Internally tracked Stats

  /// Number of timeouts
  internal(set) public var timeouts: Int = 0

  /// Number of successful reponses
  internal(set) public var successfulResponses: Int = 0

  /// Number of failed reponses
  internal(set) public var failedResponses: Int = 0

  /// Total number of requests
  internal(set) public var totalRequests: Int = 0

  /// Number of rejected requests
  internal(set) public var rejectedRequests: Int = 0

  /// Array of request latencies
  internal(set) public var executionLatencies: [Int] = []

  /// Array of request latencies
  internal(set) public var totalLatencies: [Int] = []

  /// Default latency percentiles
  public var percentiles = [0.0, 0.25, 0.5, 0.75, 0.9, 0.95, 0.99, 0.995, 1.0]

  /// Mark - Computed Statistics

  /// Method returning the cumulative latency
  public var totalLatency: Int {
    return totalLatencies.reduce(0, +)
  }

  /// Method returning the cumulative latency
  public var totalExecutionLatency: Int {
    return executionLatencies.reduce(0, +)
  }

  /// Method returning the average execution response time
  public var meanExecutionLatency: Int {
    if executionLatencies.count == 0 {
      return 0
    }
    return totalExecutionLatency / executionLatencies.count
  }

  /// Method returning the average total response time
  public var meanTotalLatency: Int {
    if totalLatencies.count == 0 {
      return 0
    }
    return totalLatency / totalLatencies.count
  }

  /// Method returning the number of concurrent requests
  public var concurrentRequests: Int {
    let totalResponses = successfulResponses + failedResponses + rejectedRequests
    return totalRequests - totalResponses
  }

  /// Percentage of responses that threw an error
  public var errorPercentage: Double {
    return Double(errorCount) / Double(totalRequests)
  }

  /// Number of errored responses
  public var errorCount: Int {
    return failedResponses
  }

  /// Latency Executes Mapping
  /// Percentile -> Execution time (in milliseconds)
  public var latencyExecute: [Double: Int] {
    return latenciesPercentiles(executionLatencies)
  }

  /// Latency Total Mapping
  /// Percentile -> Total end-to-end execution time (in milliseconds)
  public var latencyTotal: [Double: Int] {
    /// NOTE: Since CircuitBreaker does not currenly track latency for rejected requests. This simply returns
    /// the same value as latency execute
    return latenciesPercentiles(totalLatencies)
  }

  /// Number of failed executions (Both rejected and failed responses)
  public var failed: Int {
    return rejectedRequests + failedResponses
  }

  /// Number of successful executions
  public var successful: Int {
    return successfulResponses
  }

  /// Method to log current snapshot of CircuitBreaker
  public func snapshot () {
    Log.verbose("Total Requests: \(totalRequests)")
    Log.verbose("Concurrent Requests: \(concurrentRequests)")
    Log.verbose("Rejected Requests: \(rejectedRequests)")
    Log.verbose("Successful Responses: \(successfulResponses)")
    Log.verbose("Average Total Response Time: \(meanTotalLatency)")
    Log.verbose("Average Execution Response Time: \(meanExecutionLatency)")
    Log.verbose("Failed Responses: \(failedResponses)")
    Log.verbose("Total Timeouts: \(timeouts)")
    Log.verbose("Total Latency: \(totalLatency)")
  }

  internal func trackTimeouts() {
    timeouts += 1
  }

  internal func trackSuccessfulResponse() {
    successfulResponses += 1
  }

  internal func trackFailedResponse() {
    failedResponses += 1
  }

  internal func trackRejected() {
    rejectedRequests += 1
  }

  internal func trackRequest() {
    totalRequests += 1
  }

  internal func trackTotalLatency(latency: Int) {
    /// Todo: insert in order
    totalLatencies.append(latency)
  }

  internal func trackExecutionLatency(latency: Int) {
    /// Todo: insert in order
    executionLatencies.append(latency)
  }

  internal func reset() {
    self.timeouts = 0
    self.successfulResponses = 0
    self.failedResponses = 0
    self.totalRequests = 0
    self.rejectedRequests = 0
    self.totalLatencies = []
    self.executionLatencies = []
  }

  private func latenciesPercentiles(_ latencies: [Int]) -> [Double: Int] {
    let array = latencies.sorted()
    return percentiles.reduce([Double: Int]()) { acc, percentile in
      var acc = acc
      acc[percentile * 100] = percentile == 0 ? array[0] : array[Int(ceil(percentile * Double(array.count))) - 1]
      return acc
    }
  }
}
