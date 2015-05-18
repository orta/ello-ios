public struct LocalPerson {
    public let name: String
    public let emails: [String]
    public let id: Int32

    public init(name: String, emails: [String], id: Int32) {
        self.name = name
        self.emails = emails
        self.id = id
    }
}

public extension LocalPerson {
    var identifier: String {
        return "\(id)"
    }
}
