//
//  AmazonCredentials.swift
//  Ello
//
//  Created by Colin Gray on 3/2/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

class AmazonCredentials : JSONAble {
    let accessKey : String
    let endpoint : String
    let policy : String
    let prefix : String
    let signature : String

    init(accessKey: String, endpoint: String, policy: String, prefix: String, signature: String) {
        self.accessKey = accessKey
        self.endpoint = endpoint
        self.policy = policy
        self.prefix = prefix
        self.signature = signature
    }

    override class func fromJSON(data: [String : AnyObject]) -> JSONAble {
        return AmazonCredentials(
            accessKey: data["access_key"] as! String,
            endpoint:  data["endpoint"] as! String,
            policy:    data["policy"] as! String,
            prefix:    data["prefix"] as! String,
            signature: data["signature"] as! String
        )
    }
}
