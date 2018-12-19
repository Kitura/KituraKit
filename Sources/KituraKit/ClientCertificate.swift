/// Struct to store client certificate name and path
public struct ClientCertificate {
    /// The name for the client certificate
    public let name: String
    /// The path to the client certificate
    public let path: String

    /// Initialize a `ClientCertificate` instance
    public init(name: String, path: String) {
      self.name = name
      self.path = path
    }
}
