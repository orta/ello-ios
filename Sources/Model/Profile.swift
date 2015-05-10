//
//  Profile.swift
//  Ello
//
//  Created by Ryan Boyajian on 4/10/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation
import SwiftyJSON

let ProfileVersion: Int = 1

public final class Profile: JSONAble {

    // active record
    public let createdAt: NSDate
    // required
    public let shortBio: String
    public let externalLinksList: [String]
    public let email: String
    public let confirmedAt: NSDate
    public let isPublic: Bool
    public let hasAdNotificationsEnabled: Bool
    public let allowsAnalytics: Bool
    public let notifyOfCommentsViaEmail: Bool
    public let notifyOfInvitationAcceptancesViaEmail: Bool
    public let notifyOfMentionsViaEmail: Bool
    public let notifyOfNewFollowersViaEmail: Bool
    public let subscribeToUsersEmailList: Bool

    public init(createdAt: NSDate,
        shortBio: String,
        externalLinksList: [String],
        email: String,
        confirmedAt: NSDate,
        isPublic: Bool,
        hasAdNotificationsEnabled: Bool,
        allowsAnalytics: Bool,
        notifyOfCommentsViaEmail: Bool,
        notifyOfInvitationAcceptancesViaEmail: Bool,
        notifyOfMentionsViaEmail: Bool,
        notifyOfNewFollowersViaEmail: Bool,
        subscribeToUsersEmailList: Bool)
    {
        self.createdAt = createdAt
        self.shortBio = shortBio
        self.externalLinksList = externalLinksList
        self.email = email
        self.confirmedAt = confirmedAt
        self.isPublic = isPublic
        self.hasAdNotificationsEnabled = hasAdNotificationsEnabled
        self.allowsAnalytics = allowsAnalytics
        self.notifyOfCommentsViaEmail = notifyOfCommentsViaEmail
        self.notifyOfInvitationAcceptancesViaEmail = notifyOfInvitationAcceptancesViaEmail
        self.notifyOfMentionsViaEmail = notifyOfMentionsViaEmail
        self.notifyOfNewFollowersViaEmail = notifyOfNewFollowersViaEmail
        self.subscribeToUsersEmailList = subscribeToUsersEmailList
        super.init(version: ProfileVersion)
    }

// MARK: NSCoding

    public required init(coder aDecoder: NSCoder) {
        let decoder = Decoder(aDecoder)
        // active record
        self.createdAt = decoder.decodeKey("createdAt")
        // required
        self.shortBio = decoder.decodeKey("shortBio")
        self.externalLinksList = decoder.decodeKey("externalLinksList")
        self.email = decoder.decodeKey("email")
        self.confirmedAt = decoder.decodeKey("confirmedAt")
        self.isPublic = decoder.decodeKey("isPublic")
        self.hasAdNotificationsEnabled = decoder.decodeKey("hasAdNotificationsEnabled")
        self.allowsAnalytics = decoder.decodeKey("allowsAnalytics")
        self.notifyOfCommentsViaEmail = decoder.decodeKey("notifyOfCommentsViaEmail")
        self.notifyOfInvitationAcceptancesViaEmail = decoder.decodeKey("notifyOfInvitationAcceptancesViaEmail")
        self.notifyOfMentionsViaEmail = decoder.decodeKey("notifyOfMentionsViaEmail")
        self.notifyOfNewFollowersViaEmail = decoder.decodeKey("notifyOfNewFollowersViaEmail")
        self.subscribeToUsersEmailList = decoder.decodeKey("subscribeToUsersEmailList")
        super.init(coder: aDecoder)
    }

    public override func encodeWithCoder(encoder: NSCoder) {
        // active record
        encoder.encodeObject(createdAt, forKey: "createdAt")
        // required
        encoder.encodeObject(shortBio, forKey: "shortBio")
        encoder.encodeObject(externalLinksList, forKey: "externalLinksList")
        encoder.encodeObject(email, forKey: "email")
        encoder.encodeObject(confirmedAt, forKey: "confirmedAt")
        encoder.encodeBool(isPublic, forKey: "isPublic")
        encoder.encodeBool(hasAdNotificationsEnabled, forKey: "hasAdNotificationsEnabled")
        encoder.encodeBool(allowsAnalytics, forKey: "allowsAnalytics")
        encoder.encodeBool(notifyOfCommentsViaEmail, forKey: "notifyOfCommentsViaEmail")
        encoder.encodeBool(notifyOfInvitationAcceptancesViaEmail, forKey: "notifyOfInvitationAcceptancesViaEmail")
        encoder.encodeBool(notifyOfMentionsViaEmail, forKey: "notifyOfMentionsViaEmail")
        encoder.encodeBool(notifyOfNewFollowersViaEmail, forKey: "notifyOfNewFollowersViaEmail")
        encoder.encodeBool(subscribeToUsersEmailList, forKey: "subscribeToUsersEmailList")
        super.encodeWithCoder(encoder)
    }

// MARK: JSONAble

    override public class func fromJSON(data:[String: AnyObject], fromLinked: Bool = false) -> JSONAble {
        let json = JSON(data)
        // create profile
        var profile = Profile(
            createdAt: (json["created_at"].stringValue.toNSDate() ?? NSDate()),
            shortBio: json["short_bio"].stringValue,
            externalLinksList: json["external_links_list"].arrayValue.map { $0.stringValue },
            email: json["email"].stringValue,
            confirmedAt: (json["confirmed_at"].stringValue.toNSDate() ?? NSDate()),
            isPublic: json["is_public"].boolValue,
            hasAdNotificationsEnabled: json["has_ad_notifications_enabled"].boolValue,
            allowsAnalytics: json["allows_analytics"].boolValue,
            notifyOfCommentsViaEmail: json["notify_of_comments_via_email"].boolValue,
            notifyOfInvitationAcceptancesViaEmail: json["notify_of_invitation_acceptances_via_email"].boolValue,
            notifyOfMentionsViaEmail: json["notify_of_mentions_via_email"].boolValue,
            notifyOfNewFollowersViaEmail: json["notify_of_new_followers_via_email"].boolValue,
            subscribeToUsersEmailList: json["subscribe_to_users_email_list"].boolValue
        )
        return profile
    }
}
