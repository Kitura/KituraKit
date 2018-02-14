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

/// Query Parameter Decoder
/// Decodes a [String: String] object to a Decodable object instance
public class QueryDecoder: Coder, Decoder {

    public var codingPath: [CodingKey] = []

    public var userInfo: [CodingUserInfoKey : Any] = [:]

    public var dictionary: [String : String]

    public init(dictionary: [String : String]) {
        self.dictionary = dictionary
        super.init()
    }

    /// Decodes a String -> String mapping to its Decodable object representation
    ///
    /// - Parameter _ value: The Decodable object to decode the dictionary into
    public func decode<T: Decodable>(_ type: T.Type) throws -> T {
        let fieldName = Coder.getFieldName(from: codingPath)
        let fieldValue = dictionary[fieldName]
        Log.verbose("fieldName: \(fieldName), fieldValue: \(String(describing: fieldValue))")

        switch type {
        /// Ints
        case is Int.Type:
            return try decodeType(fieldValue?.int, to: T.self)
        case is Int8.Type:
            return try decodeType(fieldValue?.int8, to: T.self)
        case is Int16.Type:
            return try decodeType(fieldValue?.int16, to: T.self)
        case is Int32.Type:
            return try decodeType(fieldValue?.int32, to: T.self)
        case is Int64.Type:
            return try decodeType(fieldValue?.int64, to: T.self)
        /// Int Arrays
        case is [Int].Type:
            return try decodeType(fieldValue?.intArray, to: T.self)
        case is [Int8].Type:
            return try decodeType(fieldValue?.int8Array, to: T.self)
        case is [Int16].Type:
            return try decodeType(fieldValue?.int16Array, to: T.self)
        case is [Int32].Type:
            return try decodeType(fieldValue?.int32Array, to: T.self)
        case is [Int64].Type:
            return try decodeType(fieldValue?.int64Array, to: T.self)
        /// UInts
        case is UInt.Type:
            return try decodeType(fieldValue?.uInt, to: T.self)
        case is UInt8.Type:
            return try decodeType(fieldValue?.uInt8, to: T.self)
        case is UInt16.Type:
            return try decodeType(fieldValue?.uInt16, to: T.self)
        case is UInt32.Type:
            return try decodeType(fieldValue?.uInt32, to: T.self)
        case is UInt64.Type:
            return try decodeType(fieldValue?.uInt64, to: T.self)
        /// UInt Arrays
        case is [UInt].Type:
            return try decodeType(fieldValue?.uIntArray, to: T.self)
        case is [UInt8].Type:
            return try decodeType(fieldValue?.uInt8Array, to: T.self)
        case is [UInt16].Type:
            return try decodeType(fieldValue?.uInt16Array, to: T.self)
        case is [UInt32].Type:
            return try decodeType(fieldValue?.uInt32Array, to: T.self)
        case is [UInt64].Type:
            return try decodeType(fieldValue?.uInt64Array, to: T.self)
        /// Floats
        case is Float.Type:
            return try decodeType(fieldValue?.float, to: T.self)
        case is [Float].Type:
            return try decodeType(fieldValue?.floatArray, to: T.self)
        /// Doubles
        case is Double.Type:
            return try decodeType(fieldValue?.double, to: T.self)
        case is [Double].Type:
            return try decodeType(fieldValue?.doubleArray, to: T.self)
        /// Dates
        case is Date.Type:
            return try decodeType(fieldValue?.date(dateFormatter), to: T.self)
        case is [Date].Type:
            return try decodeType(fieldValue?.dateArray(dateFormatter), to: T.self)
        /// Strings
        case is String.Type:
            return try decodeType(fieldValue?.string, to: T.self)
        case is [String].Type:
            return try decodeType(fieldValue?.stringArray, to: T.self)
        default:
            Log.verbose("Decoding Custom Type: \(T.Type.self)")
            if fieldName.isEmpty {
                return try T(from: self)
            } else {
                // Processing an instance member of the class/struct
                return try decodeType(fieldValue?.decodable(T.self), to: T.self)
            }
        }
    }

    public func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        return KeyedDecodingContainer(KeyedContainer<Key>(decoder: self))
    }

    public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        return UnkeyedContainer(decoder: self)
    }

    public func singleValueContainer() throws -> SingleValueDecodingContainer {
        return UnkeyedContainer(decoder: self)
    }

    private func decodeType<S: Decodable, T: Decodable>(_ object: S, to type: T.Type) throws -> T {
        if let values = object as? T {
            return values
        } else {
            throw decodingError()
        }
    }

    private func decodingError() -> DecodingError {
        let fieldName = Coder.getFieldName(from: codingPath)
        let errorMsg = "Could not process field named '\(fieldName)'."
        Log.error(errorMsg)
        let errorCtx = DecodingError.Context(codingPath: codingPath, debugDescription: errorMsg)
        return DecodingError.dataCorrupted(errorCtx)
    }

    private struct KeyedContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {
        var decoder: QueryDecoder

        var codingPath: [CodingKey] { return [] }

        var allKeys: [Key] { return [] }

        func contains(_ key: Key) -> Bool {
          return decoder.dictionary[key.stringValue] != nil
        }
      
        func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
          self.decoder.codingPath.append(key)
          defer { self.decoder.codingPath.removeLast() }
          return try decoder.decode(T.self)
        }

        // If it is not in the dictionary it should be nil
        func decodeNil(forKey key: Key) throws -> Bool {
          return !contains(key)
        }

        func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
            return try decoder.container(keyedBy: type)
        }

        func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
            return try decoder.unkeyedContainer()
        }

        func superDecoder() throws -> Decoder {
            return decoder
        }

        func superDecoder(forKey key: Key) throws -> Decoder {
            return decoder
        }
    }

    private struct UnkeyedContainer: UnkeyedDecodingContainer, SingleValueDecodingContainer {
        var decoder: QueryDecoder

        var codingPath: [CodingKey] { return [] }

        var count: Int? { return nil }

        var currentIndex: Int { return 0 }

        var isAtEnd: Bool { return false }

        func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
            return try decoder.decode(type)
        }

        func decodeNil() -> Bool {
            return true
        }

        func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
            return try decoder.container(keyedBy: type)
        }

        func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
            return self
        }

        func superDecoder() throws -> Decoder {
            return decoder
        }
    }
}
