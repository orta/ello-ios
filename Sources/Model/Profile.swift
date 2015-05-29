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
    public let notifyOfLovesViaEmail: Bool
    public let notifyOfInvitationAcceptancesViaEmail: Bool
    public let notifyOfMentionsViaEmail: Bool
    public let notifyOfNewFollowersViaEmail: Bool
    public let subscribeToUsersEmailList: Bool
    public let notifyOfCommentsViaPush: Bool
    public let notifyOfLovesViaPush: Bool
    public let notifyOfMentionsViaPush: Bool
    public let notifyOfNewFollowersViaPush: Bool
    public let notifyOfInvitationAcceptancesViaPush: Bool
    // optional
    public var gaUniqueId: String?

    public init(createdAt: NSDate,
        shortBio: String,
        externalLinksList: [String],
        email: String,
        confirmedAt: NSDate,
        isPublic: Bool,
        hasAdNotificationsEnabled: Bool,
        allowsAnalytics: Bool,
        notifyOfCommentsViaEmail: Bool,
        notifyOfLovesViaEmail: Bool,
        notifyOfInvitationAcceptancesViaEmail: Bool,
        notifyOfMentionsViaEmail: Bool,
        notifyOfNewFollowersViaEmail: Bool,
        subscribeToUsersEmailList: Bool,
        notifyOfCommentsViaPush: Bool,
        notifyOfLovesViaPush : Bool,
        notifyOfMentionsViaPush: Bool,
        notifyOfNewFollowersViaPush: Bool,
        notifyOfInvitationAcceptancesViaPush: Bool)
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
        self.notifyOfLovesViaEmail = notifyOfLovesViaEmail
        self.notifyOfInvitationAcceptancesViaEmail = notifyOfInvitationAcceptancesViaEmail
        self.notifyOfMentionsViaEmail = notifyOfMentionsViaEmail
        self.notifyOfNewFollowersViaEmail = notifyOfNewFollowersViaEmail
        self.subscribeToUsersEmailList = subscribeToUsersEmailList
        self.notifyOfCommentsViaPush = notifyOfCommentsViaPush
        self.notifyOfLovesViaPush = notifyOfLovesViaPush
        self.notifyOfMentionsViaPush = notifyOfMentionsViaPush
        self.notifyOfNewFollowersViaPush = notifyOfNewFollowersViaPush
        self.notifyOfInvitationAcceptancesViaPush = notifyOfInvitationAcceptancesViaPush
        super.init(version: ProfileVersion)
    }

// MARK: NSCoding

    public required init(coder aDecoder: NSCoder) {
        let decoder = Coder(aDecoder)
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
        self.notifyOfLovesViaEmail = decoder.decodeKey("notifyOfLovesViaEmail")
        self.notifyOfInvitationAcceptancesViaEmail = decoder.decodeKey("notifyOfInvitationAcceptancesViaEmail")
        self.notifyOfMentionsViaEmail = decoder.decodeKey("notifyOfMentionsViaEmail")
        self.notifyOfNewFollowersViaEmail = decoder.decodeKey("notifyOfNewFollowersViaEmail")
        self.subscribeToUsersEmailList = decoder.decodeKey("subscribeToUsersEmailList")
        self.notifyOfCommentsViaPush = decoder.decodeKey("notifyOfCommentsViaPush")
        self.notifyOfLovesViaPush = decoder.decodeKey("notifyOfLovesViaPush")
        self.notifyOfMentionsViaPush = decoder.decodeKey("notifyOfMentionsViaPush")
        self.notifyOfNewFollowersViaPush = decoder.decodeKey("notifyOfNewFollowersViaPush")
        self.notifyOfInvitationAcceptancesViaPush = decoder.decodeKey("notifyOfInvitationAcceptancesViaPush")
        super.init(coder: decoder.coder)
    }

    public override func encodeWithCoder(encoder: NSCoder) {
        let coder = Coder(encoder)
        // active record
        coder.encodeObject(createdAt, forKey: "createdAt")
        // required
        coder.encodeObject(shortBio, forKey: "shortBio")
        coder.encodeObject(externalLinksList, forKey: "externalLinksList")
        coder.encodeObject(email, forKey: "email")
        coder.encodeObject(confirmedAt, forKey: "confirmedAt")
        coder.encodeObject(isPublic, forKey: "isPublic")
        coder.encodeObject(hasAdNotificationsEnabled, forKey: "hasAdNotificationsEnabled")
        coder.encodeObject(allowsAnalytics, forKey: "allowsAnalytics")
        coder.encodeObject(notifyOfCommentsViaEmail, forKey: "notifyOfCommentsViaEmail")
        coder.encodeObject(notifyOfLovesViaEmail, forKey: "notifyOfLovesViaEmail")
        coder.encodeObject(notifyOfInvitationAcceptancesViaEmail, forKey: "notifyOfInvitationAcceptancesViaEmail")
        coder.encodeObject(notifyOfMentionsViaEmail, forKey: "notifyOfMentionsViaEmail")
        coder.encodeObject(notifyOfNewFollowersViaEmail, forKey: "notifyOfNewFollowersViaEmail")
        coder.encodeObject(subscribeToUsersEmailList, forKey: "subscribeToUsersEmailList")
        coder.encodeObject(notifyOfCommentsViaPush, forKey: "notifyOfCommentsViaPush")
        coder.encodeObject(notifyOfLovesViaPush, forKey: "notifyOfLovesViaPush")
        coder.encodeObject(notifyOfMentionsViaPush, forKey: "notifyOfMentionsViaPush")
        coder.encodeObject(notifyOfNewFollowersViaPush, forKey: "notifyOfNewFollowersViaPush")
        coder.encodeObject(notifyOfInvitationAcceptancesViaPush, forKey: "notifyOfInvitationAcceptancesViaPush")
        super.encodeWithCoder(coder.coder)
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
            notifyOfLovesViaEmail: json["notify_of_loves_via_email"].boolValue,
            notifyOfInvitationAcceptancesViaEmail: json["notify_of_invitation_acceptances_via_email"].boolValue,
            notifyOfMentionsViaEmail: json["notify_of_mentions_via_email"].boolValue,
            notifyOfNewFollowersViaEmail: json["notify_of_new_followers_via_email"].boolValue,
            subscribeToUsersEmailList: json["subscribe_to_users_email_list"].boolValue,
            notifyOfCommentsViaPush: json["notify_of_comments_via_push"].boolValue,
            notifyOfLovesViaPush : json["notify_of_loves_via_push"].boolValue,
            notifyOfMentionsViaPush: json["notify_of_mentions_via_push"].boolValue,
            notifyOfNewFollowersViaPush: json["notify_of_new_followers_via_push"].boolValue,
            notifyOfInvitationAcceptancesViaPush: json["notify_of_invitation_acceptances_via_push"].boolValue
        )
        profile.gaUniqueId = json["ga_unique_id"].string
        return profile
    }
}
