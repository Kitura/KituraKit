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
import KituraContracts
import Kitura
import SwiftJWT

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

let initialStoreEmployee = [
    "1": Employee(id: "1", name: "Mike"),
    "2": Employee(id: "2", name: "Chris"),
    "3": Employee(id: "3", name: "Ricardo"),
    "4": Employee(id: "4", name: "Aaron"),
    "5": Employee(id: "5", name: "Mike")
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

public struct MyBasicAuth: TypeSafeMiddleware {
    
    let id: String
    
    static let users = ["John" : "12345", "Mary" : "qwerasdf"]
    
    public static func handle(request: RouterRequest, response: RouterResponse, completion: @escaping (MyBasicAuth?, RequestError?) -> Void) {
        authenticate(request: request, response: response,
           onSuccess: { (profile) in
            completion(profile, nil)
        }, onFailure: { (_,_ ) in
            completion(nil, .unauthorized)
        }, onSkip: { (_,_ ) in
            completion(nil, .unauthorized)
        })
    }
    public static func authenticate(request: RouterRequest, response: RouterResponse, onSuccess: @escaping (MyBasicAuth) -> Void, onFailure: @escaping (HTTPStatusCode?, [String : String]?) -> Void, onSkip: @escaping (HTTPStatusCode?, [String : String]?) -> Void) {
        
        let userid: String
        let password: String
        if let requestUser = request.urlURL.user, let requestPassword = request.urlURL.password {
            userid = requestUser
            password = requestPassword
        } else {
            guard let authorizationHeader = request.headers["Authorization"]  else {
                return onSkip(.unauthorized, ["WWW-Authenticate" : "Basic realm=\"User\""])
            }
            
            let authorizationHeaderComponents = authorizationHeader.components(separatedBy: " ")
            guard authorizationHeaderComponents.count == 2,
                authorizationHeaderComponents[0] == "Basic",
                let decodedData = Data(base64Encoded: authorizationHeaderComponents[1], options: Data.Base64DecodingOptions(rawValue: 0)),
                let userAuthorization = String(data: decodedData, encoding: .utf8) else {
                    return onSkip(.unauthorized, ["WWW-Authenticate" : "Basic realm=\"User\""])
            }
            let credentials = userAuthorization.components(separatedBy: ":")
            guard credentials.count >= 2 else {
                return onFailure(.badRequest, nil)
            }
            userid = credentials[0]
            password = credentials[1]
        }
        
        if let storedPassword = users[userid], storedPassword == password {
            onSuccess(MyBasicAuth(id: userid))
        } else {
            return onFailure(.unauthorized, nil)
        }
    }
}

public struct MyFacebookAuth: TypeSafeMiddleware {
    
    let id: String
    
    static let tokenProfiles = ["12345": "John", "qwerasdf": "Mary"]
    
    public static func handle(request: RouterRequest, response: RouterResponse, completion: @escaping (MyFacebookAuth?, RequestError?) -> Void) {
        authenticate(request: request, response: response,
                     onSuccess: { (profile) in
                        completion(profile, nil)
        }, onFailure: { (_,_ ) in
            completion(nil, .unauthorized)
        }, onSkip: { (_,_ ) in
            completion(nil, .unauthorized)
        })
    }
    public static func authenticate(request: RouterRequest, response: RouterResponse, onSuccess: @escaping (MyFacebookAuth) -> Void, onFailure: @escaping (HTTPStatusCode?, [String : String]?) -> Void, onSkip: @escaping (HTTPStatusCode?, [String : String]?) -> Void) {
        
        guard let type = request.headers["X-token-type"], type == "FacebookToken" else {
            return onSkip(nil, nil)
        }
        // Check whether a token has been supplied
        guard let token = request.headers["access_token"] else {
            return onFailure(nil, nil)
        }
        
        if let userProfile = tokenProfiles[token] {
            onSuccess(MyFacebookAuth(id: userProfile))
        } else {
            return onFailure(.unauthorized, nil)
        }
    }
}

public struct MyGoogleAuth: TypeSafeMiddleware {
    
    let id: String
    
    static let tokenProfiles = ["12345": "John", "qwerasdf": "Mary"]
    
    public static func handle(request: RouterRequest, response: RouterResponse, completion: @escaping (MyGoogleAuth?, RequestError?) -> Void) {
        authenticate(request: request, response: response,
                     onSuccess: { (profile) in
                        completion(profile, nil)
        }, onFailure: { (_,_ ) in
            completion(nil, .unauthorized)
        }, onSkip: { (_,_ ) in
            completion(nil, .unauthorized)
        })
    }
    public static func authenticate(request: RouterRequest, response: RouterResponse, onSuccess: @escaping (MyGoogleAuth) -> Void, onFailure: @escaping (HTTPStatusCode?, [String : String]?) -> Void, onSkip: @escaping (HTTPStatusCode?, [String : String]?) -> Void) {
        
        guard let type = request.headers["X-token-type"], type == "GoogleToken" else {
            return onSkip(nil, nil)
        }
        // Check whether a token has been supplied
        guard let token = request.headers["access_token"] else {
            return onFailure(nil, nil)
        }
        
        if let userProfile = tokenProfiles[token] {
            onSuccess(MyGoogleAuth(id: userProfile))
        } else {
            return onFailure(.unauthorized, nil)
        }
    }
}

struct MyJWTAuth<C: Claims>: TypeSafeMiddleware {
    
    let jwt: JWT<C>
    
    static func handle(request: RouterRequest, response: RouterResponse, completion: @escaping (MyJWTAuth?, RequestError?) -> Void) {
        let auth = request.headers["Authorization"]
        guard let authParts = auth?.split(separator: " ", maxSplits: 2),
            authParts.count == 2,
            authParts[0] == "Bearer",
            let key = "<PrivateKey>".data(using: .utf8),
            let jwt = try? JWT<C>(jwtString: String(authParts[1]), verifier: .hs256(key: key))
            else {
                return completion(nil, .unauthorized)
        }
        completion(MyJWTAuth(jwt: jwt), nil)
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


