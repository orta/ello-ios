//
//  AmazonCredentials.swift
//  Ello
//
//  Created by Colin Gray on 3/2/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

let AmazonCredentialsVersion = 1

public class AmazonCredentials : JSONAble {
    public let accessKey : String
    public let endpoint : String
    public let policy : String
    public let prefix : String
    public let signature : String

    public init(accessKey: String, endpoint: String, policy: String, prefix: String, signature: String) {
        self.accessKey = accessKey
        self.endpoint = endpoint
        self.policy = policy
        self.prefix = prefix
        self.signature = signature
        super.init(version: AmazonCredentialsVersion)
    }

    public required init(coder aDecoder: NSCoder) {
        let decoder = Decoder(aDecoder)
        self.accessKey = decoder.decodeKey("accessKey")
        self.endpoint = decoder.decodeKey("endpoint")
        self.policy = decoder.decodeKey("policy")
        self.prefix = decoder.decodeKey("prefix")
        self.signature = decoder.decodeKey("signature")
        super.init(coder: aDecoder)
    }

    override public class func fromJSON(data: [String : AnyObject], fromLinked: Bool = false) -> JSONAble {
        return AmazonCredentials(
            accessKey: data["access_key"] as! String,
            endpoint:  data["endpoint"] as! String,
            policy:    data["policy"] as! String,
            prefix:    data["prefix"] as! String,
            signature: data["signature"] as! String
        )
    }
}
