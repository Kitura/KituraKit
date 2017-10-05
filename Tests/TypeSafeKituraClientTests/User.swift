import Foundation

// Models/entities
// I am now wondering if we should make all entities model conform to Codable
// and a new custom protocol that requires an identifier field...
// if we do so, then we don't need to pass the identifier field as a separate parameter... TBD...
public struct User: Codable, Equatable {
    public let id: Int
    public let name: String
    public init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}

public func ==(lhs: User, rhs: User) -> Bool {
    return lhs.id == rhs.id && lhs.name == rhs.name
}
