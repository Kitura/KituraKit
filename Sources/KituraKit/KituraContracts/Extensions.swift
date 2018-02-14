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
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Foundation

/// Codable String Conversion Extension
extension String {

    /// Converts the given String to an Int?
    public var int: Int? {
        return Int(self)
    }

    /// Converts the given String to a Int8?
    public var int8: Int8? {
        return Int8(self)
    }

    /// Converts the given String to a Int16?
    public var int16: Int16? {
        return Int16(self)
    }

    /// Converts the given String to a Int32?
    public var int32: Int32? {
        return Int32(self)
    }

    /// Converts the given String to a Int64?
    public var int64: Int64? {
        return Int64(self)
    }

    /// Converts the given String to a UInt?
    public var uInt: UInt? {
        return UInt(self)
    }

    /// Converts the given String to a UInt8?
    public var uInt8: UInt8? {
        return UInt8(self)
    }

    /// Converts the given String to a UInt16?
    public var uInt16: UInt16? {
        return UInt16(self)
    }

    /// Converts the given String to a UInt32?
    public var uInt32: UInt32? {
        return UInt32(self)
    }

    /// Converts the given String to a UInt64?
    public var uInt64: UInt64? {
        return UInt64(self)
    }

    /// Converts the given String to a Float?
    public var float: Float? {
        return Float(self)
    }

    /// Converts the given String to a Double?
    public var double: Double? {
        return Double(self)
    }

    /// Converts the given String to a Bool?
    public var boolean: Bool? {
        return Bool(self)
    }

    /// Converts the given String to a String
    public var string: String {
        return self
    }

    /// Converts the given String to an [Int]?
    public var intArray: [Int]? {
        return decodeArray(Int.self)
    }

    /// Converts the given String to an [Int8]?
    public var int8Array: [Int8]? {
        return decodeArray(Int8.self)
    }

    /// Converts the given String to an [Int16]?
    public var int16Array: [Int16]? {
        return decodeArray(Int16.self)
    }

    /// Converts the given String to an [Int32]?
    public var int32Array: [Int32]? {
        return decodeArray(Int32.self)
    }

    /// Converts the given String to an [Int64]?
    public var int64Array: [Int64]? {
        return decodeArray(Int64.self)
    }

    /// Converts the given String to an [UInt]?
    public var uIntArray: [UInt]? {
        return decodeArray(UInt.self)
    }

    /// Converts the given String to an [UInt8]?
    public var uInt8Array: [UInt8]? {
        return decodeArray(UInt8.self)
    }

    /// Converts the given String to an [UInt16]?
    public var uInt16Array: [UInt16]? {
        return decodeArray(UInt16.self)
    }

    /// Converts the given String to an [UInt32]?
    public var uInt32Array: [UInt32]? {
        return decodeArray(UInt32.self)
    }

    /// Converts the given String to an [UInt64]?
    public var uInt64Array: [UInt64]? {
        return decodeArray(UInt64.self)
    }

    /// Converts the given String to a [Float]?
    public var floatArray: [Float]? {
        return decodeArray(Float.self)
    }

    /// Converts the given String to a [Double]?
    public var doubleArray: [Double]? {
        return decodeArray(Double.self)
    }

    /// Converts the given String to a [Bool]?
    public var booleanArray: [Bool]? {
        return decodeArray(Bool.self)
    }

    /// Converts the given String to a [String]
    public var stringArray: [String] {
        let strs: [String] = self.components(separatedBy: ",")
        return strs
    }

    /// Method used to decode a string into the given type T
    ///
    /// - Parameters:
    ///     - _ type: The Decodable type to convert the string into.
    /// - Returns: The Date? object. Some on success / nil on failure
    public func decodable<T: Decodable>(_ type: T.Type) -> T? {
        guard let data = self.data(using: .utf8) else {
            return nil
        }
        let obj: T? = try? JSONDecoder().decode(type, from: data)
        return obj
    }

    /// Converts the given String to a Date?
    ///
    /// - Parameters:
    ///     - _ formatter: The designated DateFormatter to convert the string with.
    /// - Returns: The Date? object. Some on success / nil on failure
    public func date(_ formatter: DateFormatter) -> Date? {
        return formatter.date(from: self)
    }

    /// Converts the given String to a [Date]?
    ///
    /// - Parameters:
    ///     - _ formatter: The designated DateFormatter to convert the string with.
    /// - Returns: The [Date]? object. Some on success / nil on failure
    public func dateArray(_ formatter: DateFormatter) -> [Date]? {
        let strs: [String] = self.components(separatedBy: ",")
        let dates = strs.map { formatter.date(from: $0) }.filter { $0 != nil }.map { $0! }
        if dates.count == strs.count {
            return dates
        }
        return nil
    }

    /// Helper Method to decode a string to an LosslessStringConvertible array types
    private func decodeArray<T: LosslessStringConvertible>(_ type: T.Type) -> [T]? {
        let strs: [String] = self.components(separatedBy: ",")
        let values: [T] = strs.map { T($0) }.filter { $0 != nil }.map { $0! }
        return values.count == strs.count ? values : nil
    }
}
