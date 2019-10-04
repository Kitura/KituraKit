/*
 * Copyright IBM Corporation 2017-2019
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
import KituraContracts

// Models/entities (application/use case specific)
public struct User: Codable, Equatable {
    public let id: Int
    public let name: String
    public let date: Date
    public init(id: Int, name: String, date: Date) {
        self.id = id
        self.name = name
        self.date = date
    }

    public static func ==(lhs: User, rhs: User) -> Bool {
        return (lhs.id == rhs.id) && (lhs.name == rhs.name) && (lhs.date == rhs.date)
    }

}

struct CodableDate: Codable, Equatable {
    let date: Date
    init(date: Date) {
        self.date = date
    }
    public static func == (lhs: CodableDate, rhs: CodableDate) -> Bool {
        return lhs.date == rhs.date
    }
}

public struct UserOptional: Codable, Equatable {
    public let id: Int?
    public let name: String?
    public init(id: Int, name: String) {
        self.id = id
        self.name = name
    }

    public static func ==(lhs: UserOptional, rhs: UserOptional) -> Bool {
        return (lhs.id == rhs.id) && (lhs.name == rhs.name)
    }

}

public struct Employee: Codable, Equatable {
    public let id: String
    public let name: String

    public static func ==(lhs: Employee, rhs: Employee) -> Bool {
        return (lhs.id == rhs.id) && (lhs.name == rhs.name)
    }
}

public struct UserQuery: QueryParams {
    let name: String
}
let date = Date(timeIntervalSince1970: 1519206456)
let initialStore = [
    "1": User(id: 1, name: "Mike", date: date),
    "2": User(id: 2, name: "Chris", date: date),
    "3": User(id: 3, name: "Ricardo", date: date),
    "4": User(id: 4, name: "Aaron", date: date),
    "5": User(id: 5, name: "Mike", date: date)
]

public struct Status: Codable, Equatable {
    let description: String
    init(_ desc: String) {
        description = desc
    }
    public static func == (lhs: Status, rhs: Status) -> Bool {
        return lhs.description == rhs.description
    }
}


struct AccessToken: Codable {
    let accessToken: String
}

struct JWTUser: Codable, Equatable {
    let name: String

    public static func ==(lhs: JWTUser, rhs: JWTUser) -> Bool {
        return (lhs.name == rhs.name)
    }
}
