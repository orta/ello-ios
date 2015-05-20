//
//  PushPayload.swift
//  Ello
//
//  Created by Gordon Fontenot on 5/20/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public struct PushPayload {
    let info: [String: AnyObject]
}

public extension PushPayload {
    var applicationTarget: String {
        return info["application_target"] as? String ?? ""
    }
}
