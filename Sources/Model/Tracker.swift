//
//  Tracker.swift
//  Ello
//
//  Created by Gordon Fontenot on 4/9/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Analytics
import Keys

public enum ContentType: String {
    case Post = "Post"
    case Comment = "Comment"
}

public protocol AnalyticsAgent {
    func identify(userId: String!, traits: [NSObject : AnyObject]!)
    func track(event: String!)
    func screen(screenTitle: String!)
    func reset()
}

public struct NullAgent: AnalyticsAgent {
    public func identify(userId: String!, traits: [NSObject : AnyObject]!) { }
    public func track(event: String!) { }
    public func screen(screenTitle: String!) { }
    public func reset() { }
}

extension SEGAnalytics: AnalyticsAgent { }

public class Tracker {
    public static let sharedTracker = Tracker()

    private var shouldTrackUser = true
    private var agent: AnalyticsAgent {
        return shouldTrackUser ? SEGAnalytics.sharedAnalytics() : NullAgent()
    }

    public init() {
        let configuration = SEGAnalyticsConfiguration(writeKey: ElloKeys().segmentKey())
         SEGAnalytics.setupWithConfiguration(configuration)
    }
}

// MARK: Session Info
public extension Tracker {
    func identify(user: User) {
        shouldTrackUser = user.profile?.allowsAnalytics ?? true
        if let analyticsId = user.profile?.gaUniqueId {
            agent.identify(analyticsId, traits: [ "created_at": user.profile?.createdAt.toNSString() ?? "no-creation-date" ])
        }
    }

    func sessionStarted() {
        agent.track("Session Began")
    }

    func sessionEnded() {
        agent.track("Session Ended")
    }
}

// MARK: View Appearance
public extension Tracker {
    func screenAppeared(name: String) {
        agent.screen(name)
    }

    func viewedImage() {
        agent.track("Viewed Image")
    }

    func postBarVisibilityChanged(visible: Bool) {
        let visibility = visible ? "shown" : "hidden"
        agent.track("Post bar \(visibility)")
    }

    func commentBarVisibilityChanged(visible: Bool) {
        let visibility = visible ? "shown" : "hidden"
        agent.track("Comment bar \(visibility)")
    }

    func drawerClosed() {
        agent.track("Drawer closed")
    }

    func viewsButtonTapped() {
        agent.track("Views button tapped")
    }
}

// MARK: Content Actions
public extension Tracker {
    func contentCreated(type: ContentType) {
        agent.track("\(type.rawValue) created")
    }

    func contentCreationCanceled(type: ContentType) {
        agent.track("\(type.rawValue) creation canceled")
    }

    func contentCreationFailed(type: ContentType, message: String) {
        agent.track("\(type.rawValue) creation failed: \(message)")
    }

    func contentFlagged(type: ContentType, flag: ContentFlagger.AlertOption) {
        agent.track("\(type.rawValue) flagged: \(flag.rawValue)")
    }

    func contentFlaggingCanceled(type: ContentType) {
        agent.track("\(type.rawValue) flagging canceled")
    }

    func contentFlaggingFailed(type: ContentType, message: String) {
        agent.track("\(type.rawValue) flagging failed: \(message)")
    }

    func postReposted() {
        agent.track("Post reposted")
    }

    func postShared() {
        agent.track("Post shared")
    }

    func postLoved() {
        agent.track("Post loved")
    }
}

// MARK: User Actions
public extension Tracker {
    func userBlocked() {
        agent.track("User blocked")
    }

    func userMuted() {
        agent.track("User muted")
    }

    func userBlockCanceled() {
        agent.track("User block canceled")
    }

    func friendAdded() {
        agent.track("Friend added")
    }

    func noiseAdded() {
        agent.track("Noise added")
    }

    func friendInvited() {
        agent.track("User invited")
    }
}

// MARK: Image Actions
public extension Tracker {
    func imageAddedFromCamera() {
        agent.track("Image added from camera")
    }

    func imageAddedFromLibrary() {
        agent.track("Image added from library")
    }

    func addImageCanceled() {
        agent.track("Image addition canceled")
    }
}

// MARK: Import Friend Actions
public extension Tracker {
    func inviteFriendsTapped() {
        agent.track("Invite Friends tapped")
    }

    func importContactsInitiated() {
        agent.track("Import Contacts initiated")
    }

    func importContactsDenied() {
        agent.track("Import Contacts denied")
    }

    func addressBookAccessed() {
        agent.track("Address book accessed")
    }
}

// MARK:  Preferences
public extension Tracker {
    func pushNotificationPreferenceChanged(enabled: Bool) {
        let accessLevel = enabled ? "enabled" : "denied"
        agent.track("Push notification access \(accessLevel)")
    }

    func contactAccessPreferenceChanged(enabled: Bool) {
        let accessLevel = enabled ? "enabled" : "denied"
        agent.track("Address book access \(accessLevel)")
    }
}

// MARK: Errors
public extension Tracker {
    func encounteredNetworkError(error: NSError) {
        agent.track("Encountered network error: \(error.description)")
    }
}
