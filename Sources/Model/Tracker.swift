//
//  Tracker.swift
//  Ello
//
//  Created by Gordon Fontenot on 4/9/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Analytics
import Keys
import Crashlytics

public enum ContentType: String {
    case Post = "Post"
    case Comment = "Comment"
}

public protocol AnalyticsAgent {
    func identify(userId: String!, traits: [NSObject : AnyObject]!)
    func track(event: String!)
    func track(event: String!, properties: [NSObject: AnyObject]!)
    func screen(screenTitle: String!)
    func screen(screenTitle: String!, properties: [NSObject: AnyObject]!)
    func reset()
}

public struct NullAgent: AnalyticsAgent {
    public func identify(userId: String!, traits: [NSObject : AnyObject]!) { }
    public func track(event: String!) { }
    public func track(event: String!, properties: [NSObject: AnyObject]!) { }
    public func screen(screenTitle: String!) { }
    public func screen(screenTitle: String!, properties: [NSObject: AnyObject]!) { }
    public func reset() { }
}

extension SEGAnalytics: AnalyticsAgent { }

public class Tracker {
    public static var responseHeaders: NSString = ""
    public static var responseJSON: NSString = ""

    public var overrideAgent: AnalyticsAgent?
    public static let sharedTracker = Tracker()
    var settingChangedNotification: NotificationObserver?
    private var shouldTrackUser = true
    private var currentUser: User?
    private var agent: AnalyticsAgent {
        return overrideAgent ?? (shouldTrackUser ? SEGAnalytics.sharedAnalytics() : NullAgent())
    }

    public init() {
        let configuration = SEGAnalyticsConfiguration(writeKey: ElloKeys().segmentKey())
         SEGAnalytics.setupWithConfiguration(configuration)

        settingChangedNotification = NotificationObserver(notification: SettingChangedNotification) { user in
            self.shouldTrackUser = user.profile?.allowsAnalytics ?? true
            Crashlytics.sharedInstance().setUserIdentifier(self.shouldTrackUser ? user.id : "")
        }
    }
}

// MARK: Session Info
public extension Tracker {
    func log(message: String) {
        // print("------ \(message) ------")
    }

    func identify(user: User) {
        currentUser = user
        shouldTrackUser = user.profile?.allowsAnalytics ?? true
        Crashlytics.sharedInstance().setUserIdentifier(shouldTrackUser ? user.id : "")
        if let analyticsId = user.profile?.gaUniqueId {
            agent.identify(analyticsId, traits: [ "created_at": user.profile?.createdAt.toServerDateString() ?? "no-creation-date" ])
        }
    }

    func sessionStarted() {
        log("Session Began")
        agent.track("Session Began")
    }

    func sessionEnded() {
        log("Session Ended")
        agent.track("Session Ended")
    }
}

// MARK: Signup and Login
public extension Tracker {

    func tappedJoinFromStartup() {
        log("tapped join from startup")
        agent.track("tapped join from startup")
    }

    func tappedSignInFromStartup() {
        log("tapped sign in from startup")
        agent.track("tapped sign in from startup")
    }

    func tappedJoinFromSignIn() {
        log("tapped join from sign-in")
        agent.track("tapped join from sign-in")
    }

    func tappedSignInFromJoin() {
        log("tapped sign in from join")
        agent.track("tapped sign in from join")
    }

    func enteredEmail() {
        log("entered email and pressed 'next'")
        agent.track("entered email and pressed 'next'")
    }

    func enteredUsername() {
        log("entered username and pressed 'next'")
        agent.track("entered username and pressed 'next'")
    }

    func enteredPassword() {
        log("entered password and pressed 'next'")
        agent.track("entered password and pressed 'next'")
    }

    func tappedJoin() {
        log("tapped join")
        agent.track("tapped join")
    }

    func tappedAbout() {
        log("tapped about")
        agent.track("tapped about")
    }

    func tappedTsAndCs() {
        log("tapped terms and conditions")
        agent.track("tapped terms and conditions")
    }

    func joinValid() {
        log("join valid")
        agent.track("join valid")
    }

    func joinInvalid() {
        log("join invalid")
        agent.track("join invalid")
    }

    func joinSuccessful() {
        log("join successful")
        agent.track("join successful")
    }

    func joinFailed() {
        log("join failed")
        agent.track("join failed")
    }

    func tappedSignIn() {
        log("tapped sign in")
        agent.track("tapped sign in")
    }

    func signInValid() {
        log("sign-in valid")
        agent.track("sign-in valid")
    }

    func signInInvalid() {
        log("sign-in invalid")
        agent.track("sign-in invalid")
    }

    func signInSuccessful() {
        log("sign-in successful")
        agent.track("sign-in successful")
    }

    func signInFailed() {
        log("sign-in failed")
        agent.track("sign-in failed")
    }

    func tappedForgotPassword() {
        log("forgot password tapped")
        agent.track("forgot password tapped")
    }

    func tappedLogout() {
        log("logout tapped")
        agent.track("logout tapped")
    }

}

// MARK: iRate
public extension Tracker {
    func ratePromptShown() {
        log("rate prompt shown")
        agent.track("rate prompt shown")
    }

    func ratePromptUserDeclinedToRateApp() {
        log("rate prompt user declined to rate app")
        agent.track("rate prompt user declined to rate app")
    }

    func ratePromptRemindMeLater() {
        log("rate prompt remind me later")
        agent.track("rate prompt remind me later")
    }

    func ratePromptUserAttemptedToRateApp() {
        log("rate prompt user attempted to rate app")
        agent.track("rate prompt user attempted to rate app")
    }

    func ratePromptOpenedAppStore() {
        log("rate prompt opened app store")
        agent.track("rate prompt opened app store")
    }

    func ratePromptCouldNotConnectToAppStore() {
        log("rate prompt could not connect to app store")
        agent.track("rate prompt could not connect to app store")
    }
}

// MARK: Onboarding
public extension Tracker {
    func skippedCommunities() {
        log("skipped communities")
        agent.track("skipped communities")
    }

    func completedCommunities() {
        log("completed communities")
        agent.track("completed communities")
    }

    func followedAllFeatured() {
        log("followed all featured")
        agent.track("followed all featured")
    }

    func followedSomeFeatured() {
        log("followed some featured")
        agent.track("followed some featured")
    }

    func skippedContactImport() {
        log("skipped contact import")
        agent.track("skipped contact import")
    }

    func completedContactImport() {
        log("completed contact import")
        agent.track("completed contact import")
    }

    func skippedCoverImage() {
        log("skipped cover image")
        agent.track("skipped cover image")
    }

    func completedCoverImage() {
        log("completed cover image")
        agent.track("completed cover image")
    }

    func skippedAvatar() {
        log("skipped avatar")
        agent.track("skipped avatar")
    }

    func completedAvatar() {
        log("completed avatar")
        agent.track("completed avatar")
    }

    func skippedNameBio() {
        log("skipped name_bio")
        agent.track("skipped name_bio")
    }

    func addedNameBio() {
        log("added name_bio")
        agent.track("added name_bio")
    }
}

public extension UIViewController {
    func trackerName() -> String { return readableClassName() }
    func trackerProps() -> [NSObject:AnyObject]? { return nil }

    func trackerData() -> (String, [NSObject:AnyObject]?) {
        return (trackerName(), trackerProps())
    }
}

// MARK: View Appearance
public extension Tracker {
    func screenAppeared(viewController: UIViewController) {
        let (name, props) = viewController.trackerData()
        screenAppeared(name, properties: props)
    }

    func tabAppeared(viewController: UIViewController) {
        screenAppeared(viewController)
    }

    func screenAppeared(name: String, properties: [NSObject:AnyObject]? = nil) {
        log("Screen: \(name)")
        agent.screen(name, properties: properties)
    }

    func streamAppeared(kind: String) {
        log("Screen: Stream, [kind: \(kind)]")
        agent.screen("Stream", properties: ["kind": kind])
    }

    func webViewAppeared(url: String) {
        log("Screen: Web View, [url: \(url)]")
        agent.screen("Web View", properties: ["url": url])
    }

    func profileLoaded(handle: String) {
        log("Profile Loaded, [handle: \(handle)]")
        agent.track("Profile Loaded", properties: ["handle": handle])
    }

    func ownProfileViewed(handle: String) {
        log("Screen: Own Profile Viewed, [handle: \(handle)]")
        agent.screen("Own Profile Viewed", properties: ["handle": handle])
    }

    func profileViewed(handle: String) {
        log("Screen: Profile Viewed, [handle: \(handle)]")
        agent.screen("Profile Viewed", properties: ["handle": handle])
    }

    func postLoaded(id: String) {
        log("Post Loaded, [id: \(id)]")
        agent.track("Post Loaded", properties: ["id": id])
    }

    func postViewed(id: String) {
        log("Post Viewed, [id: \(id)]")
        agent.screen("Post Viewed", properties: ["id": id])
    }

    func viewedImage(asset: Asset, post: Post) {
        log("Viewed Image, [asset_id: \(asset.id), post_id: \(post.id)]")
        agent.track("Viewed Image", properties: ["asset_id": asset.id, "post_id": post.id])
    }

    func postBarVisibilityChanged(visible: Bool) {
        let visibility = visible ? "shown" : "hidden"
        log("Post bar \(visibility)")
        agent.track("Post bar \(visibility)")
    }

    func commentBarVisibilityChanged(visible: Bool) {
        let visibility = visible ? "shown" : "hidden"
        log("Comment bar \(visibility)")
        agent.track("Comment bar \(visibility)")
    }

    func drawerClosed() {
        log("Drawer closed")
        agent.track("Drawer closed")
    }

    func viewsButtonTapped(post post: Post) {
        log("Views button tapped, [post_id: \(post.id)]")
        agent.track("Views button tapped", properties: ["post_id": post.id])
    }

    func deepLinkVisited(path: String) {
        log("Deep Link Visited, [path: \(path)]")
        agent.track("Deep Link Visited", properties: ["path": path])
    }
}

// MARK: Content Actions
public extension Tracker {
    private func regionDetails(regions: [Regionable]?) -> [String: AnyObject] {
        guard let regions = regions else {
            return [:]
        }

        var imageCount = 0
        var textLength = 0
        for region in regions {
            if region.kind == RegionKind.Image.rawValue {
                imageCount += 1
            }
            else if let region = region as? TextRegion {
                textLength += region.content.characters.count
            }
        }

        return [
            "total_regions": regions.count,
            "image_regions": imageCount,
            "text_length": textLength
        ]
    }

    func postCreated(post: Post) {
        let type: ContentType = .Post
        let properties = regionDetails(post.content)
        log("\(type.rawValue) created")
        agent.track("\(type.rawValue) created", properties: properties)
    }

    func postEdited(post: Post) {
        let type: ContentType = .Post
        let properties = regionDetails(post.content)
        log("\(type.rawValue) edited")
        agent.track("\(type.rawValue) edited", properties: properties)
    }

    func commentCreated(comment: Comment) {
        let type: ContentType = .Comment
        let properties = regionDetails(comment.content)
        log("\(type.rawValue) created")
        agent.track("\(type.rawValue) created", properties: properties)
    }

    func commentEdited(comment: Comment) {
        let type: ContentType = .Comment
        let properties = regionDetails(comment.content)
        log("\(type.rawValue) edited")
        agent.track("\(type.rawValue) edited", properties: properties)
    }

    func contentCreated(type: ContentType) {
        log("\(type.rawValue) created")
        agent.track("\(type.rawValue) created")
    }

    func contentEdited(type: ContentType) {
        log("\(type.rawValue) edited")
        agent.track("\(type.rawValue) edited")
    }

    func contentCreationCanceled(type: ContentType) {
        log("\(type.rawValue) creation canceled")
        agent.track("\(type.rawValue) creation canceled")
    }

    func contentEditingCanceled(type: ContentType) {
        log("\(type.rawValue) editing canceled")
        agent.track("\(type.rawValue) editing canceled")
    }

    func contentCreationFailed(type: ContentType, message: String) {
        log("\(type.rawValue) creation failed, [message: \(message)]")
        agent.track("\(type.rawValue) creation failed", properties: ["message": message])
    }

    func contentFlagged(type: ContentType, flag: ContentFlagger.AlertOption, contentId: String) {
        log("\(type.rawValue) flagged, [content_id: \(contentId), flag: \(flag.rawValue)]")
        agent.track("\(type.rawValue) flagged", properties: ["content_id": contentId, "flag": flag.rawValue])
    }

    func contentFlaggingCanceled(type: ContentType, contentId: String) {
        log("\(type.rawValue) flagging canceled, [content_id: \(contentId)]")
        agent.track("\(type.rawValue) flagging canceled", properties: ["content_id": contentId])
    }

    func contentFlaggingFailed(type: ContentType, message: String, contentId: String) {
        log("\(type.rawValue) flagging failed, [content_id: \(contentId), message: \(message)]")
        agent.track("\(type.rawValue) flagging failed", properties: ["content_id": contentId, "message": message])
    }

    func postReposted(post: Post) {
        log("Post reposted, [post_id: \(post.id)]")
        agent.track("Post reposted", properties: ["post_id": post.id])
    }

    func postShared(post: Post) {
        log("Post shared, [post_id: \(post.id)]")
        agent.track("Post shared", properties: ["post_id": post.id])
    }

    func postLoved(post: Post) {
        log("Post loved, [post_id: \(post.id)]")
        agent.track("Post loved", properties: ["post_id": post.id])
    }

    func postUnloved(post: Post) {
        log("Post unloved, [post_id: \(post.id)]")
        agent.track("Post unloved", properties: ["post_id": post.id])
    }
}

// MARK: User Actions
public extension Tracker {
    func userBlocked(userId: String) {
        log("User blocked, [blocked_user_id: \(userId)]")
        agent.track("User blocked", properties: ["blocked_user_id": userId])
    }

    func userMuted(userId: String) {
        log("User muted, [muted_user_id: userId]")
        agent.track("User muted", properties: ["muted_user_id": userId])
    }

    func userBlockCanceled(userId: String) {
        log("User block canceled, [blocked_user_id: userId]")
        agent.track("User block canceled", properties: ["blocked_user_id": userId])
    }

    func relationshipStatusUpdated(relationshipPriority: RelationshipPriority, userId: String) {
        log("Relationship Priority changed, [relationship: \(relationshipPriority.rawValue), user_id: \(userId)]")
        agent.track("Relationship Priority changed", properties: ["new_value": relationshipPriority.rawValue, "user_id": userId])
    }

    func relationshipStatusUpdateFailed(relationshipPriority: RelationshipPriority, userId: String) {
        log("Relationship Priority failed, [relationship: \(relationshipPriority.rawValue), user_id: \(userId)]")
        agent.track("Relationship Priority failed", properties: ["new_value": relationshipPriority.rawValue, "user_id": userId])
    }

    func relationshipButtonTapped(relationshipPriority: RelationshipPriority, userId: String) {
        log("Relationship button tapped")
        agent.track("Relationship button tapped", properties: ["button": relationshipPriority.buttonName, "user_id": userId])
    }

    func friendInvited() {
        log("User invited")
        agent.track("User invited")
    }

    func userDeletedAccount() {
        log("User deleted account")
        agent.track("User deleted account")
    }
}

// MARK: Image Actions
public extension Tracker {
    func imageAddedFromCamera() {
        log("Image added from camera")
        agent.track("Image added from camera")
    }

    func imageAddedFromLibrary() {
        log("Image added from library")
        agent.track("Image added from library")
    }

    func addImageCanceled() {
        log("Image addition canceled")
        agent.track("Image addition canceled")
    }
}

// MARK: Import Friend Actions
public extension Tracker {
    func inviteFriendsTapped() {
        log("Invite Friends tapped")
        agent.track("Invite Friends tapped")
    }

    func importContactsInitiated() {
        log("Import Contacts initiated")
        agent.track("Import Contacts initiated")
    }

    func importContactsDenied() {
        log("Import Contacts denied")
        agent.track("Import Contacts denied")
    }

    func addressBookAccessed() {
        log("Address book accessed")
        agent.track("Address book accessed")
    }
}

// MARK:  Preferences
public extension Tracker {
    func pushNotificationPreferenceChanged(granted: Bool) {
        let accessLevel = granted ? "granted" : "denied"
        log("Push notification access \(accessLevel)")
        agent.track("Push notification access \(accessLevel)")
    }

    func contactAccessPreferenceChanged(granted: Bool) {
        let accessLevel = granted ? "granted" : "denied"
        log("Address book access \(accessLevel)")
        agent.track("Address book access \(accessLevel)")
    }
}

// MARK: Errors
public extension Tracker {
    func encounteredNetworkError(path: String, error: NSError, statusCode: Int?) {
        log("Encountered network error, [path: \(path), message: \(error.description), statusCode: \(statusCode ?? 0)]")
        agent.track("Encountered network error", properties: ["path": path, "message": error.description, "statusCode": statusCode ?? 0])
    }

    func createdAtCrash(identifier: String, json: String?) {
        let jsonText: NSString = json ?? Tracker.responseJSON
        agent.track("\(identifier) Created At Crash", properties: ["responseHeaders": Tracker.responseHeaders, "responseJSON": jsonText, "currentUserId": currentUser?.id ?? "no id"])
    }
}

// MARK: Search
public extension Tracker {
    func searchFor(type: String) {
        agent.track("Search for \(type)")
    }
}
