//
//  Availability.swift
//  Ello
//
//  Created by Tony DiPasquale on 3/31/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Crashlytics
import SwiftyJSON

let AvailabilityVersion = 1

@objc(Availability)
public final class Availability: JSONAble {
    public let isUsernameAvailable: Bool
    public let isEmailAvailable: Bool
    public let isInvitationCodeAvailable: Bool
    public let usernameSuggestions: [String]
    public let emailSuggestion: String

    public init(isUsernameAvailable: Bool, isEmailAvailable: Bool, isInvitationCodeAvailable: Bool, usernameSuggestions: [String], emailSuggestion: String) {
        self.isUsernameAvailable = isUsernameAvailable
        self.isEmailAvailable = isEmailAvailable
        self.isInvitationCodeAvailable = isInvitationCodeAvailable
        self.usernameSuggestions = usernameSuggestions
        self.emailSuggestion = emailSuggestion
        super.init(version: AvailabilityVersion)
    }

    public required init(coder aDecoder: NSCoder) {
        let decoder = Coder(aDecoder)
        self.isUsernameAvailable = decoder.decodeKey("isUsernameAvailable")
        self.isEmailAvailable = decoder.decodeKey("isEmailAvailable")
        self.isInvitationCodeAvailable = decoder.decodeKey("isInvitationCodeAvailable")
        self.usernameSuggestions = decoder.decodeKey("usernameSuggestions")
        self.emailSuggestion = decoder.decodeKey("emailSuggestion")
        super.init(coder: aDecoder)
    }
}

extension Availability {
    override public class func fromJSON(data: [String: AnyObject], fromLinked: Bool = false) -> JSONAble {
        let json = JSON(data)
        Crashlytics.sharedInstance().setObjectValue(json.rawString(), forKey: CrashlyticsKey.AvailabilityFromJSON.rawValue)
        let username = json["username"].boolValue
        let email = json["email"].boolValue
        let invitationCode = json["invitation_code"].boolValue
        let usernameSuggestions = json["suggestions"]["username"].arrayValue.map { $0.stringValue }
        let emailSuggestion = json["suggestions"]["email"]["full"].stringValue

        return Availability(isUsernameAvailable: username, isEmailAvailable: email, isInvitationCodeAvailable: invitationCode, usernameSuggestions: usernameSuggestions, emailSuggestion: emailSuggestion)
    }
}
