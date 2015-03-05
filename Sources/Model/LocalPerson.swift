struct LocalPerson {
    let name: String
    let emails: [String]
    let id: Int32
}

extension LocalPerson {
    var identifier: String {
        return "\(id)"
    }

    var emailHashes: [String] {
        return emails.reduce([]) { $0 + ($1.SHA1String.map { [$0] } ?? []) }
    }
}
