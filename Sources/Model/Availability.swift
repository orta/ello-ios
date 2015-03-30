//
//  Availability.swift
//  Ello
//
//  Created by Tony DiPasquale on 3/31/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import SwiftyJSON

final class Availability: JSONAble {
    let username: Bool
    let email: Bool
    let invitationCode: Bool
    let usernameSuggestions: [String]
    let emailSuggestion: String

    init(username: Bool, email: Bool, invitationCode: Bool, usernameSuggestions: [String], emailSuggestion: String) {
        self.username = username
        self.email = email
        self.invitationCode = invitationCode
        self.usernameSuggestions = usernameSuggestions
        self.emailSuggestion = emailSuggestion
    }
}

extension Availability {
    override class func fromJSON(data: [String: AnyObject]) -> JSONAble {
        let json = JSON(data)
        let username = json["username"].boolValue
        let email = json["email"].boolValue
        let invitationCode = json["invitation_code"].boolValue
        let usernameSuggestions = json["suggestions"]["username"].arrayValue.map { $0.stringValue }
        let emailSuggestion = json["suggestions"]["email"]["full"].stringValue

        return Availability(username: username, email: email, invitationCode: invitationCode, usernameSuggestions: usernameSuggestions, emailSuggestion: emailSuggestion)
    }
}
