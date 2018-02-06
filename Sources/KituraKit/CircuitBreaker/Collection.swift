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

/// Generic Semaphore protected queue
class Collection<T> {

    internal let semaphoreQueue = DispatchSemaphore(value: 1)
    internal var list: [T]
    let size: Int

    var isEmpty: Bool {
        semaphoreQueue.wait()
        let empty = list.isEmpty
        semaphoreQueue.signal()
        return empty
    }

    var count: Int {
        semaphoreQueue.wait()
        let count = list.count
        semaphoreQueue.signal()
        return count
    }

    init(size: Int) {
        self.size = size
        self.list = [T]()
    }

    func add(_ element: T) {
        semaphoreQueue.wait()
        list.append(element)
        if list.count > size {
            list.removeFirst()
        }
        semaphoreQueue.signal()
    }

    func removeFirst() -> T? {
        semaphoreQueue.wait()
        let element: T? = list.removeFirst()
        semaphoreQueue.signal()
        return element
    }

    func removeLast() -> T? {
        semaphoreQueue.wait()
        let element: T? = list.removeLast()
        semaphoreQueue.signal()
        return element
    }

    func peekFirst() -> T? {
        semaphoreQueue.wait()
        let element: T? = list.first
        semaphoreQueue.signal()
        return element
    }

    func peekLast() -> T? {
        semaphoreQueue.wait()
        let element: T? = list.last
        semaphoreQueue.signal()
        return element
    }

    func clear() {
        semaphoreQueue.wait()
        list.removeAll()
        semaphoreQueue.signal()
    }
}

/// Failure queue
class FailureQueue: Collection<UInt64> {
    var currentTimeWindow: UInt64? {
        semaphoreQueue.wait()
        // Get time difference
        let timeWindow: UInt64?
        if let firstFailureTs = list.first, let lastFailureTs = list.last {
            timeWindow = lastFailureTs - firstFailureTs
        } else {
            timeWindow = nil
        }
        semaphoreQueue.signal()
        return timeWindow
    }
}
