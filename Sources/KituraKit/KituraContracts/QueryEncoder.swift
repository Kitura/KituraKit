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

extension CharacterSet {
    static let customURLQueryAllowed = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~=:&")
}

/**
 Query Parameter Encoder.
 
 Encodes an `Encodable` object to a query parameter string, a `URLQueryItemArray`, or to a `[String: String]` dictionary. The encode function takes the `Encodable` object to encode as the parameter.
 
 ### Usage Example: ###
 ````swift
 let date = Coder().dateFormatter.date(from: "2017-10-31T16:15:56+0000")
 let query = MyQuery(intField: -1, optionalIntField: 282, stringField: "a string", intArray: [1, -1, 3], dateField: date, optionalDateField: date, nested: Nested(nestedIntField: 333, nestedStringField: "nested string"))
 
 guard let myQueryDict: [String: String] = try? QueryEncoder().encode(query) else {
     print("Failed to encode query to [String: String]")
     return
 }
 ````
 */
public class QueryEncoder: Coder, Encoder {

    /**
     A `[String: String]` dictionary.
     */
    internal var dictionary: [String: String]

    internal var anyDictionary: [String: Any]

    /**
     The coding key path.
     
     ### Usage Example: ###
     ````swift
     let fieldName = Coder.getFieldName(from: codingPath)
     ````
     */
    public var codingPath: [CodingKey] = []

    /**
     The coding user info key.
     */
    public var userInfo: [CodingUserInfoKey: Any] = [:]

    /**
     Initializer for the dictionary, which initializes an empty `[String: String]` dictionary.
     */
    public override init() {
        self.dictionary = [:]
        self.anyDictionary = [:]
        super.init()
    }

    /**
     Encodes an Encodable object to a query parameter string.
     
     - Parameter value: The Encodable object to encode to its String representation.
     
     ### Usage Example: ###
     ````swift
     guard let myQueryStr: String = try? QueryEncoder().encode(query) else {
         print("Failed to encode query to String")
         return
     }
     ````
     */
    public func encode<T: Encodable>(_ value: T) throws -> String {
        let dict: [String : String] = try encode(value)
        let desc: String = dict.map { key, value in "\(key)=\(value)" }
            .reduce("") {pair1, pair2 in "\(pair1)&\(pair2)"}
            .addingPercentEncoding(withAllowedCharacters: CharacterSet.customURLQueryAllowed)!
        return "?" + String(desc.dropFirst())
    }

    /**
     Encodes an Encodable object to a URLQueryItem array.
     
     - Parameter value: The Encodable object to encode to its [URLQueryItem] representation.
     
     ### Usage Example: ###
     ````swift
     guard let myQuery2 = try? QueryDecoder(dictionary: myQueryDict).decode(T.self) else {
         print("Failed to decode query to MyQuery object")
         return
     }
     ````
     */
    public func encode<T: Encodable>(_ value: T) throws -> [URLQueryItem] {
        let dict: [String : String] = try encode(value)
        return dict.reduce([URLQueryItem]()) { array, element in
            var array = array
            array.append(URLQueryItem(name: element.key, value: element.value))
            return array
        }
    }

    /**
     Encodes an Encodable object to a `[String: String]` dictionary.
     
     - Parameter value: The Encodable object to encode to its `[String: String]` representation.
     
     ### Usage Example: ###
     ````swift
     guard let myQueryDict: [String: String] = try? QueryEncoder().encode(query) else {
         print("Failed to encode query to [String: String]")
         return
     }
     ````
     */
    public func encode<T: Encodable>(_ value: T) throws -> [String : String] {
        try value.encode(to: self)
        return self.dictionary
    }

    /// Encodes an Encodable object to a String -> String dictionary
    ///
    /// - Parameter _ value: The Encodable object to encode to its [String: String] representation
    public func encode<T: Encodable>(_ value: T) throws -> [String : Any] {
        try value.encode(to: self)
        return self.anyDictionary
    }

    /**
     Returns a keyed encoding container based on the key type.
     
     ### Usage Example: ###
     ````swift
     encoder.container(keyedBy: keyType)
     ````
     */

    public func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        return KeyedEncodingContainer(KeyedContainer<Key>(encoder: self))
    }

    /**
     Returns an unkeyed encoding container.
     
     ### Usage Example: ###
     ````swift
     encoder.unkeyedContainer()
     ````
     */
    public func unkeyedContainer() -> UnkeyedEncodingContainer {
        return UnkeyedContanier(encoder: self)
    }
    
    /**
     Returns an single value encoding container based on the key type.
     
     ### Usage Example: ###
     ````swift
     encoder.singleValueContainer()
     ````
     */
    public func singleValueContainer() -> SingleValueEncodingContainer {
        return UnkeyedContanier(encoder: self)
    }

    internal func encodingError(_ value: Any, underlyingError: Swift.Error?) -> EncodingError {
        let fieldName = Coder.getFieldName(from: codingPath)
        let errorCtx = EncodingError.Context(codingPath: codingPath, debugDescription: "Could not process field named '\(fieldName)'.", underlyingError: underlyingError)
        return EncodingError.invalidValue(value, errorCtx)
    }

    private struct KeyedContainer<Key: CodingKey>: KeyedEncodingContainerProtocol {
        var encoder: QueryEncoder

        var codingPath: [CodingKey] { return [] }

        func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
            self.encoder.codingPath.append(key)
            defer { self.encoder.codingPath.removeLast() }
            let fieldName = Coder.getFieldName(from: self.encoder.codingPath)

            switch value {
            /// Ints
            case let fieldValue as Int:
                encoder.dictionary[fieldName] = String(fieldValue)
                encoder.anyDictionary[fieldName] = fieldValue
            case let fieldValue as Int8:
                encoder.dictionary[fieldName] = String(fieldValue)
                encoder.anyDictionary[fieldName] = fieldValue
            case let fieldValue as Int16:
                encoder.dictionary[fieldName] = String(fieldValue)
                encoder.anyDictionary[fieldName] = fieldValue
            case let fieldValue as Int32:
                encoder.dictionary[fieldName] = String(fieldValue)
                encoder.anyDictionary[fieldName] = fieldValue
            case let fieldValue as Int64:
                encoder.dictionary[fieldName] = String(fieldValue)
                encoder.anyDictionary[fieldName] = fieldValue
            /// Int Arrays
            case let fieldValue as [Int]:
                let strs: [String] = fieldValue.map { String($0) }
                encoder.dictionary[fieldName] = strs.joined(separator: ",")
                encoder.anyDictionary[fieldName] = fieldValue
            case let fieldValue as [Int8]:
                let strs: [String] = fieldValue.map { String($0) }
                encoder.dictionary[fieldName] = strs.joined(separator: ",")
                encoder.anyDictionary[fieldName] = fieldValue
            case let fieldValue as [Int16]:
                let strs: [String] = fieldValue.map { String($0) }
                encoder.dictionary[fieldName] = strs.joined(separator: ",")
                encoder.anyDictionary[fieldName] = fieldValue
            case let fieldValue as [Int32]:
                let strs: [String] = fieldValue.map { String($0) }
                encoder.dictionary[fieldName] = strs.joined(separator: ",")
                encoder.anyDictionary[fieldName] = fieldValue
            case let fieldValue as [Int64]:
                let strs: [String] = fieldValue.map { String($0) }
                encoder.dictionary[fieldName] = strs.joined(separator: ",")
                encoder.anyDictionary[fieldName] = fieldValue
            /// UInts
            case let fieldValue as UInt:
                encoder.dictionary[fieldName] = String(fieldValue)
                encoder.anyDictionary[fieldName] = fieldValue
            /// Int Arrays
            case let fieldValue as UInt8:
                encoder.dictionary[fieldName] = String(fieldValue)
                encoder.anyDictionary[fieldName] = fieldValue
            /// Int Arrays
            case let fieldValue as UInt16:
                encoder.dictionary[fieldName] = String(fieldValue)
                encoder.anyDictionary[fieldName] = fieldValue
            /// Int Arrays
            case let fieldValue as UInt32:
                encoder.dictionary[fieldName] = String(fieldValue)
                encoder.anyDictionary[fieldName] = fieldValue
            /// Int Arrays
            case let fieldValue as UInt64:
                encoder.dictionary[fieldName] = String(fieldValue)
                encoder.anyDictionary[fieldName] = fieldValue
            /// Int Arrays
            /// UInt Arrays
            case let fieldValue as [UInt]:
                let strs: [String] = fieldValue.map { String($0) }
                encoder.dictionary[fieldName] = strs.joined(separator: ",")
                encoder.anyDictionary[fieldName] = fieldValue
            /// Int Arrays
            case let fieldValue as [UInt8]:
                let strs: [String] = fieldValue.map { String($0) }
                encoder.dictionary[fieldName] = strs.joined(separator: ",")
                encoder.anyDictionary[fieldName] = fieldValue
            case let fieldValue as [UInt16]:
                let strs: [String] = fieldValue.map { String($0) }
                encoder.dictionary[fieldName] = strs.joined(separator: ",")
                encoder.anyDictionary[fieldName] = fieldValue
            case let fieldValue as [UInt32]:
                let strs: [String] = fieldValue.map { String($0) }
                encoder.dictionary[fieldName] = strs.joined(separator: ",")
                encoder.anyDictionary[fieldName] = fieldValue
            case let fieldValue as [UInt64]:
                let strs: [String] = fieldValue.map { String($0) }
                encoder.dictionary[fieldName] = strs.joined(separator: ",")
                encoder.anyDictionary[fieldName] = fieldValue
            /// Floats
            case let fieldValue as Float:
                encoder.dictionary[fieldName] = String(fieldValue)
                encoder.anyDictionary[fieldName] = fieldValue
            case let fieldValue as [Float]:
                let strs: [String] = fieldValue.map { String($0) }
                encoder.dictionary[fieldName] = strs.joined(separator: ",")
                encoder.anyDictionary[fieldName] = fieldValue
            /// Doubles
            case let fieldValue as Double:
                encoder.dictionary[fieldName] = String(fieldValue)
                encoder.anyDictionary[fieldName] = fieldValue
            case let fieldValue as [Double]:
                let strs: [String] = fieldValue.map { String($0) }
                encoder.dictionary[fieldName] = strs.joined(separator: ",")
                encoder.anyDictionary[fieldName] = fieldValue
            /// Bools
            case let fieldValue as Bool:
                encoder.dictionary[fieldName] = String(fieldValue)
                encoder.anyDictionary[fieldName] = fieldValue
            case let fieldValue as [Bool]:
                let strs: [String] = fieldValue.map { String($0) }
                encoder.dictionary[fieldName] = strs.joined(separator: ",")
                encoder.anyDictionary[fieldName] = fieldValue
            /// Strings
            case let fieldValue as String:
                encoder.dictionary[fieldName] = fieldValue
                encoder.anyDictionary[fieldName] = fieldValue
            case let fieldValue as [String]:
                encoder.dictionary[fieldName] = fieldValue.joined(separator: ",")
                encoder.anyDictionary[fieldName] = fieldValue
            /// Dates
            case let fieldValue as Date:
                encoder.dictionary[fieldName] = encoder.dateFormatter.string(from: fieldValue)
                encoder.anyDictionary[fieldName] = fieldValue
            case let fieldValue as [Date]:
                let strs: [String] = fieldValue.map { encoder.dateFormatter.string(from: $0) }
                encoder.dictionary[fieldName] = strs.joined(separator: ",")
                encoder.anyDictionary[fieldName] = fieldValue
            case let fieldValue as Operation:
                encoder.dictionary[fieldName] = fieldValue.getStringValue()
                encoder.anyDictionary[fieldName] = fieldValue
            case let fieldValue as Ordering:
                encoder.dictionary[fieldName] = fieldValue.getStringValue()
                encoder.anyDictionary[fieldName] = fieldValue
            case let fieldValue as Pagination:
                encoder.dictionary[fieldName] = fieldValue.getStringValue()
                encoder.anyDictionary[fieldName] = fieldValue
            default:
                if fieldName.isEmpty {
                    encoder.dictionary = [:]   // Make encoder instance reusable
                    encoder.anyDictionary = [:]   // Make encoder instance reusable
                    try value.encode(to: encoder)
                } else {
                    do {
                        let jsonData = try JSONEncoder().encode(value)
                        encoder.dictionary[fieldName] = String(data: jsonData, encoding: .utf8)
                        encoder.anyDictionary[fieldName] = jsonData
                    } catch let error {
                        throw encoder.encodingError(value, underlyingError: error)
                    }
                }
            }
        }

        func encodeNil(forKey: Key) throws {}

        func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
              return encoder.container(keyedBy: keyType)
        }

        func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
            return encoder.unkeyedContainer()
        }

        func superEncoder() -> Encoder {
            return encoder
        }

        func superEncoder(forKey key: Key) -> Encoder {
            return encoder
        }
    }

    private struct UnkeyedContanier: UnkeyedEncodingContainer, SingleValueEncodingContainer {
        var encoder: QueryEncoder

        var codingPath: [CodingKey] { return [] }

        var count: Int { return 0 }

        func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
            return encoder.container(keyedBy: keyType)
        }

        func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
            return self
        }

        func superEncoder() -> Encoder {
            return encoder
        }

        func encodeNil() throws {}

        func encode<T>(_ value: T) throws where T : Encodable {
            let _: [String : String] = try encoder.encode(value)
        }
    }
}
