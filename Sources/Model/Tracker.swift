//
//  Tracker.swift
//  Ello
//
//  Created by Gordon Fontenot on 4/9/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//


public enum ContentType: String {
    case Post = "Post"
    case Comment = "Comment"
}

private let AnalyticsAPIKey = ""

public struct Tracker {
    public static let sharedTracker = Tracker()

    public init() {
        // authenticate with Segment.io
        // let configuration = SEGAnalyticsConfiguration.configurationWithKey(AnalyticsAPIKey)
        // SEGAnalytics.setupWithConfiguration(configuration)
    }
}

public extension Tracker {
    func identify(user: User) {
        // SEGAnalytics.sharedAnalytics().identify(user.userId,
        //                                          traits: {
        //                                              "name": user.name,
        //                                              "email": user.email ?? "None Provided"
        //                                          })
    }
}

public extension Tracker {
    func sessionStarted() { }
    func sessionEnded() { }

    func screenAppeared(name: String) { }

    func contentCreated(type: ContentType) { }
    func contentCreationCanceled(type: ContentType) { }
    func contentCreationFailed(type: ContentType, message: String) { }

    func contentFlagged(type: ContentType, flag: ContentFlagger.AlertOption) { }
    func contentFlaggingCanceled(type: ContentType) { }
    func contentFlaggingFailed(type: ContentType, message: String) { }

    func viewedImage() { }

    func postBarVisibilityChanged(visible: Bool) { }
    func postReposted() { }
    func postShared() { }
    func postLoved() { }
    func inlineCommentsViewed() { }

    func userBlocked() { }
    func userMuted() { }
    func userBlockCanceled() { }

    func imageAddedFromCamera() { }
    func imageAddedFromLibrary() { }
    func addImageCanceled() { }

    func inviteFriendsTapped() { }
    func friendAdded() { }
    func noiseAdded() { }
    func friendInvited() { }
    func importContactsInitiated() { }
    func importContactsDenied() { }
    func addressBookAccessed() { }

    func pushNotificationPreferenceChanged(enabled: Bool) { }
    func contactAccessPreferenceChanged(enabled: Bool) { }

    func drawerClosed() { }

    func viewsButtonTapped() { }

    func encounteredNetworkError(error: NSError) { }
}
