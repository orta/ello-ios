import Foundation

let LocalPersonVersion = 1

@objc(LocalPerson)
public final class LocalPerson: JSONAble {
    public let name: String
    public let emails: [String]
    public let id: Int32

    public var identifier: String {
        return "\(id)"
    }
    
    public init(name: String, emails: [String], id: Int32) {
        self.name = name
        self.emails = emails
        self.id = id
        super.init(version: LocalPersonVersion)
    }

    public required init(coder aDecoder: NSCoder) {
        let decoder = Coder(aDecoder)
        self.name = decoder.decodeKey("name")
        self.emails = decoder.decodeKey("emails")
        self.id = decoder.decodeKey("id")
        super.init(coder: decoder.coder)
    }

    public override func encodeWithCoder(encoder: NSCoder) {
        let coder = Coder(encoder)
        coder.encodeObject(name, forKey: "name")
        coder.encodeObject(emails, forKey: "emails")
        coder.encodeObject(id, forKey: "id")
        super.encodeWithCoder(coder.coder)
    }
    
    // this shouldn't ever get called
    public override class func fromJSON(data: [String: AnyObject], fromLinked: Bool = false) -> JSONAble {
        return LocalPerson(name: "Unknown", emails: ["unknown@example.com"], id: 1)
    }
}
