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

    func contentFlagged(content: String, flag: ContentFlagger.AlertOption) { }
    func contentFlaggingCanceled(content: String) { }

    func postBarVisibilityChanged(visible: Bool) { }

    func viewedImage() { }

    func postReposted() { }
    func postShared() { }

    func inlineCommentsViewed() { }

    func userBlocked() { }
    func userMuted() { }
    func userBlockCanceled() { }

    func imageAddedFromCamera() { }
    func imageAddedFromLibrary() { }
    func addImageCanceled() { }

    func friendAdded(fromFindScreen: Bool = false) { }
    func userInvited() { }

    func pushNotificationPreferenceChanged(enabled: Bool) { }
    func contactAccessPreferenceChanged(enabled: Bool) { }

    func drawerClosed() { }

    func viewsButtonTapped() { }

    func encounteredNetworkError(error: NSError) { }
}
