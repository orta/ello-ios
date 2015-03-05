struct LocalPerson {
    let name: String
    let emails: [String]
    let id: Int32
}

extension LocalPerson {
    var nameHash: String {
        return name.SHA1String ?? ""
    }

    var emailHashes: [String] {
        return emails.reduce([]) { $0 + ($1.SHA1String.map { [$0] } ?? []) }
    }
}
