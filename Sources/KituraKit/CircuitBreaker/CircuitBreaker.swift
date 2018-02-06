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

/// CircuitBreaker class
///
/// - A: Parameter types used in the arguments for the command closure.
/// - B: Parameter type used as the second argument for the fallback closure.
public class CircuitBreaker<A, B> {

  // MARK: Closure Aliases

  public typealias AnyContextFunction<A> = (Invocation<A, B>) -> Void
  public typealias AnyFallback<B> = (BreakerError, B) -> Void

  // MARK: Public Fields

  /// Name of Circuit Breaker Instance
  public private(set) var name: String

  // Name of Circuit Breaker Group
  public private(set) var group: String?

  /// Execution timeout for command contect (Default: 1000 ms)
  public let timeout: Int

  /// Timeout to reset circuit (Default: 6000 ms)
  public let resetTimeout: Int

  /// Maximum number of failures allowed before opening circuit (Default: 5)
  public let maxFailures: Int

  /// (Default: 10000 ms)
  public let rollingWindow: Int

  /// Instance of Circuit Breaker Stats
  public let breakerStats = Stats()

  /// The Breaker's Current State
  public private(set) var breakerState: State {
    get {
      return state
    }
    set {
      state = newValue
    }
  }

  private(set) var state = State.closed
  private let failures: FailureQueue
  //fallback function is invoked ONLY when failing fast OR when timing out OR when application
  //notifies circuit that command did not complete successfully.
  private let fallback: AnyFallback<B>
  private let command: AnyContextFunction<A>
  private let bulkhead: Bulkhead?

  /// Dispatch
  private var resetTimer: DispatchSourceTimer?
  private let semaphoreCircuit = DispatchSemaphore(value: 1)

  private let queue = DispatchQueue(label: "Circuit Breaker Queue", attributes: .concurrent)

  // MARK: Initializers

  /// Initializes CircuitBreaker instance with asyncronous context command (Advanced usage)
  ///
  /// - Parameters:
  ///   - name: name of the circuit instance
  ///   - group: optional group description
  ///   - timeout: Execution timeout for command contect (Default: 1000 ms)
  ///   - resetTimeout: Timeout to reset circuit (Default: 6000 ms)
  ///   - maxFailures: Maximum number of failures allowed before opening circuit (Default: 5)
  ///   - rollingWindow: (Default: 10000 ms)
  ///   - bulkhead: Number of the limit of concurrent requests running at one time.
  ///     Default is set to 0, which is equivalent to not using the bulkheading feature.(Default: 0)
  ///   - command: Contextual function to circuit break, which allows user defined failures
  ///     (the context provides an indirect reference to the corresponding circuit breaker instance).
  ///   - fallback: Function user specifies to signal timeout or fastFail completion.
  ///     Required format: (BreakerError, (fallbackArg1, fallbackArg2,...)) -> Void
  ///
  public init(name: String,
              group: String? = nil,
              timeout: Int = 1000,
              resetTimeout: Int = 60000,
              maxFailures: Int = 5,
              rollingWindow: Int = 10000,
              bulkhead: Int = 0,
              command: @escaping AnyContextFunction<A>,
              fallback: @escaping AnyFallback<B>) {
    self.name = name
    self.group = group
    self.timeout = timeout
    self.resetTimeout = resetTimeout
    self.maxFailures = maxFailures
    self.rollingWindow = rollingWindow
    self.fallback = fallback
    self.command = command
    self.failures = FailureQueue(size: maxFailures)
    self.bulkhead = (bulkhead > 0) ? Bulkhead.init(limit: bulkhead) : nil

    // Link to Observers

    MonitorCollection.sharedInstance.values.forEach { $0.register(breakerRef: self) }
  }

  // MARK: Class Methods

  /// Runs the circuit using the provided arguments
  /// - Parameters:
  ///   - commandArgs: Arguments of type `A` for the circuit command
  ///   - fallbackArgs: Arguments of type `B` for the circuit fallback
  ///
  public func run(commandArgs: A, fallbackArgs: B) {
    breakerStats.trackRequest()

    switch breakerState {
    case .open:
      fastFail(fallbackArgs: fallbackArgs)

    case .halfopen:
      let startTime = Date()

      if let bulkhead = self.bulkhead {
          bulkhead.enqueue {
              self.callFunction(startTime: startTime, commandArgs: commandArgs, fallbackArgs: fallbackArgs)
          }
      } else {
          callFunction(startTime: startTime, commandArgs: commandArgs, fallbackArgs: fallbackArgs)
      }

    case .closed:
      let startTime = Date()

      if let bulkhead = self.bulkhead {
          bulkhead.enqueue {
              self.callFunction(startTime: startTime, commandArgs: commandArgs, fallbackArgs: fallbackArgs)
          }
      } else {
          callFunction(startTime: startTime, commandArgs: commandArgs, fallbackArgs: fallbackArgs)
      }
    }
  }

  /// Method to print current stats
  public func logSnapshot() {
    breakerStats.snapshot()
  }

  /// Method to notifcy circuit of a completion with a failure
  internal func notifyFailure(error: BreakerError, fallbackArgs: B) {
    handleFailure(error: error, fallbackArgs: fallbackArgs)
  }

  /// Method to notifcy circuit of a successful completion
  internal func notifySuccess() {
    handleSuccess()
  }

  /// Method to force the circuit open
  public func forceOpen() {
    semaphoreCircuit.wait()
    open()
    semaphoreCircuit.signal()
  }

  /// Method to force the circuit closed
  public func forceClosed() {
    semaphoreCircuit.wait()
    close()
    semaphoreCircuit.signal()
  }

  /// Method to force the circuit halfopen
  public func forceHalfOpen() {
    breakerState = .halfopen
  }

  /// Wrapper for calling and handling CircuitBreaker command
  private func callFunction(startTime: Date, commandArgs: A, fallbackArgs: B) {

    let invocation = Invocation(startTime: startTime, breaker: self, commandArgs: commandArgs, fallbackArgs: fallbackArgs)

    setTimeout { [weak invocation, weak self] in
      if invocation?.nofityTimedOut() == true {
        self?.handleFailure(error: .timeout, fallbackArgs: fallbackArgs)
      }
    }

    // Invoke command
    command(invocation)
  }

  /// Wrapper for setting the command timeout and updating breaker stats
  private func setTimeout(closure: @escaping () -> Void) {
    queue.asyncAfter(deadline: .now() + .milliseconds(self.timeout)) { [weak self] in
      self?.breakerStats.trackTimeouts()
      closure()
    }
  }

  /// The current number of failures
  internal var numberOfFailures: Int {
    return failures.count
  }

  /// Handler for a circuit failure.
  private func handleFailure(error: BreakerError, fallbackArgs: B) {
    semaphoreCircuit.wait()
    Log.verbose("Handling failure...")

    // Add a new failure
    failures.add(Date.currentTimeMillis())

    // Get time difference between oldest and newest failure
    let timeWindow: UInt64? = failures.currentTimeWindow

    defer {
      // Invoking callback after updating circuit stats and state
      // This way we eliminate the possibility of a deadlock and/or
      // holding on to the semaphore for a long time because the fallback
      // method has not returned.
      fallback(error, fallbackArgs)
    }

    defer {
      breakerStats.trackFailedResponse()
      semaphoreCircuit.signal()
    }

    if state == .halfopen {
      Log.verbose("Failed in halfopen state.")
      open()
      return
    }

    if let timeWindow = timeWindow {
      if failures.count >= maxFailures && timeWindow <= UInt64(rollingWindow) {
        Log.verbose("Reached maximum number of failures allowed before tripping circuit.")
        open()
        return
      }
    }

  }

  /// Command success handler
  private func handleSuccess() {
    semaphoreCircuit.wait()
    Log.verbose("Handling success...")

    if state == .halfopen {
      close()
    }
    breakerStats.trackSuccessfulResponse()
    semaphoreCircuit.signal()
  }

  /**
  * This function should be called within the boundaries of a semaphore.
  * Otherwise, resulting behavior may be unexpected.
  */
  private func close() {
    // Remove all failures (i.e. reset failure counter to 0)
    failures.clear()
    breakerState = .closed
  }

  /**
  * This function should be called within the boundaries of a semaphore.
  * Otherwise, resulting behavior may be unexpected.
  */
  private func open() {
    breakerState = .open
    startResetTimer(delay: .milliseconds(resetTimeout))
  }

  /// Fast fail handler
  private func fastFail(fallbackArgs: B) {
    Log.verbose("Breaker open... failing fast.")
    breakerStats.trackRejected()
    fallback(.fastFail, fallbackArgs)
  }

  /// Reset timer setup
  private func startResetTimer(delay: DispatchTimeInterval) {
    // Cancel previous timer if any
    resetTimer?.cancel()

    resetTimer = DispatchSource.makeTimerSource(queue: queue)

    resetTimer?.setEventHandler { [weak self] in
      self?.forceHalfOpen()
    }

    resetTimer?.schedule(deadline: .now() + delay)

    resetTimer?.resume()
  }
}

extension CircuitBreaker: StatsProvider {

  /// Method to create link a StatsMonitor Instance
  public static func addMonitor(monitor: StatsMonitor) {
    MonitorCollection.sharedInstance.values.append(monitor)
  }

  /// Property to compute snapshot
  public var snapshot: Snapshot {
    return Snapshot(name: name, group: group, stats: self.breakerStats, state: breakerState)
  }
}
