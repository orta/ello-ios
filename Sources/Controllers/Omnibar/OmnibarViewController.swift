//
//  OmnibarViewController.swift
//  Ello
//
//  Created by Sean on 1/15/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit
import Crashlytics

public class OmnibarViewController: BaseElloViewController, OmnibarScreenDelegate {
    var keyboardWillShowObserver: NotificationObserver?
    var keyboardWillHideObserver: NotificationObserver?

    override public var tabBarItem: UITabBarItem? {
        get { return UITabBarItem.svgItem("omni") }
        set { self.tabBarItem = newValue }
    }

    var previousTab: ElloTab = .DefaultTab
    var parentPost: Post?
    var editPost: Post?
    var defaultText: String?

    typealias CommentSuccessListener = (comment: Comment) -> Void
    typealias PostSuccessListener = (post: Post) -> Void
    var commentSuccessListener: CommentSuccessListener?
    var postSuccessListener: PostSuccessListener?

    var _mockScreen: OmnibarScreenProtocol?
    public var screen: OmnibarScreenProtocol {
        set(screen) { _mockScreen = screen }
        get { return _mockScreen ?? self.view as! OmnibarScreen }
    }

    convenience public init(parentPost post: Post) {
        self.init(nibName: nil, bundle: nil)
        parentPost = post
    }

    convenience public init(editPost post: Post) {
        self.init(nibName: nil, bundle: nil)
        editPost = post

        var defaultText = ""
        if let regions = post.content {
            for region in regions {
                if let textRegion = region as? TextRegion {
                    defaultText += textRegion.content
                }
            }
        }
        self.defaultText = defaultText
    }

    convenience public init(parentPost post: Post, defaultText: String) {
        self.init(parentPost: post)
        self.defaultText = defaultText
    }

    public func omnibarDataName() -> String {
        if let post = parentPost {
            return "omnibar_comment_\(post.repostId ?? post.id)"
        }
        else if let post = editPost {
            return "omnibar_post_\(post.repostId ?? post.id)"
        }
        else {
            return "omnibar_post"
        }
    }

    func onCommentSuccess(listener: CommentSuccessListener) {
        commentSuccessListener = listener
    }

    func onPostSuccess(listener: PostSuccessListener) {
        postSuccessListener = listener
    }

    override public func loadView() {
        self.view = OmnibarScreen(frame: UIScreen.mainScreen().bounds)

        screen.canGoBack = parentPost != nil || editPost != nil
        screen.currentUser = currentUser
        screen.text = defaultText
        if parentPost != nil {
            screen.title = NSLocalizedString("Leave a comment", comment: "Leave a comment")
        }
        else if editPost != nil {
            screen.title = NSLocalizedString("Edit this post", comment: "Edit this post")
        }

        let fileName = omnibarDataName()
        if let data: NSData = Tmp.read(fileName) {
            if let omnibarData = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? OmnibarData {
                if let prevAttributedText = omnibarData.attributedText {
                    let currentText = screen.text
                    let trimmedText = screen.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())

                    if let currentText = currentText, let trimmedText = trimmedText where prevAttributedText.string.contains(currentText) || prevAttributedText.string.endsWith(trimmedText)  {
                        screen.attributedText = prevAttributedText
                    }
                    else {
                        screen.appendAttributedText(prevAttributedText)
                    }
                }
                screen.image = omnibarData.image
            }
            Tmp.remove(fileName)
        }
        screen.delegate = self
    }

    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .None)
        UIApplication.sharedApplication().statusBarStyle = .LightContent

        if let previousTab = elloTabBarController?.previousTab {
            self.previousTab = previousTab
        }

        if let cachedImage = TemporaryCache.load(.Avatar) {
            screen.avatarImage = cachedImage
        }
        else {
            screen.avatarURL = currentUser?.avatarURL
        }

        keyboardWillShowObserver = NotificationObserver(notification: Keyboard.Notifications.KeyboardWillShow, block: self.willShow)
        keyboardWillHideObserver = NotificationObserver(notification: Keyboard.Notifications.KeyboardWillHide, block: self.willHide)

        let isShowingNarration = elloTabBarController?.shouldShowNarration ?? false
        if !isShowingNarration && presentedViewController == nil {
            // desired behavior: animate the keyboard in when this screen is
            // shown.  without the delay, the keyboard just appears suddenly.
            delay(0) {
                self.screen.startEditing()
            }
        }

        screen.updatePostState()
    }

    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        elloTabBarController?.setTabBarHidden(false, animated: animated)
        Crashlytics.sharedInstance().setObjectValue("Omnibar", forKey: CrashlyticsKey.StreamName.rawValue)
    }

    override public func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        if let keyboardWillShowObserver = keyboardWillShowObserver {
            keyboardWillShowObserver.removeObserver()
            self.keyboardWillShowObserver = nil
        }
        if let keyboardWillHideObserver = keyboardWillHideObserver {
            keyboardWillHideObserver.removeObserver()
            self.keyboardWillHideObserver = nil
        }
    }

    func willShow(keyboard: Keyboard) {
        screen.keyboardWillShow()
    }

    func willHide(keyboard: Keyboard) {
        screen.keyboardWillHide()
    }

    override func didSetCurrentUser() {
        super.didSetCurrentUser()
        if isViewLoaded() {
            if let cachedImage = TemporaryCache.load(.Avatar) {
                screen.avatarImage = cachedImage
            }
            else {
                screen.avatarURL = currentUser?.avatarURL
            }
        }
    }

    public func omnibarCancel() {
        if screen.text == "Crashlytics.crash('test')" {
            Crashlytics.sharedInstance().crash()
        }
        if parentPost != nil || editPost != nil {
            let omnibarData = OmnibarData(attributedText: screen.attributedText, image: screen.image)
            let data = NSKeyedArchiver.archivedDataWithRootObject(omnibarData)
            Tmp.write(data, to: omnibarDataName())

            if parentPost != nil {
                Tracker.sharedTracker.contentCreationCanceled(.Comment)
            }
            else if editPost != nil {
                Tracker.sharedTracker.contentCreationCanceled(.Post)
            }
            navigationController?.popViewControllerAnimated(true)
        }
        else {
            Tracker.sharedTracker.contentCreationCanceled(.Post)
            goToPreviousTab()
        }
    }

    public func omnibarSubmitted(text: NSAttributedString?, image: UIImage, data: NSData, type: String) {
        omnibarSubmitted(text, image: nil, data: (image, data, type))
    }

    public func omnibarSubmitted(text: NSAttributedString?, image: UIImage?) {
        omnibarSubmitted(text, image: image, data: nil)
    }

    public func omnibarSubmitted(text: NSAttributedString?, image: UIImage?, data: (UIImage, NSData, String)?) {
        var content = [Any]()

        if let data = data {
            content.append(data)
        }
        else if let image = image {
            content.append(image)
        }

        if let text = text?.string {
            if count(text) > 5000 {
                contentCreationFailed(NSLocalizedString("Your text is too long.\n\nThe character limit is 5,000.", comment: "Post too long (maximum characters is 5000) error message"))
                return
            }

            let cleanedText = text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            if count(cleanedText) > 0 {
                content.append(text)
            }
        }

        let service : PostEditingService
        if let parentPost = parentPost {
            service = PostEditingService(parentPost: parentPost)
        }
        else if let editPost = editPost {
            service = PostEditingService(editPost: editPost)
        }
        else {
            service = PostEditingService()
        }

        if count(content) > 0 {
            ElloHUD.showLoadingHud()
            if let authorId = currentUser?.id {
                service.create(
                    content: content,
                    authorId: authorId,
                    success: { postOrComment in
                        ElloHUD.hideLoadingHud()

                        if let parentPost = self.parentPost {
                            var comment = postOrComment as! Comment
                            self.emitCommentSuccess(comment)
                        }
                        else {
                            var post = postOrComment as! Post
                            self.emitPostSuccess(post)
                        }
                    },
                    failure: { error, statusCode in
                        ElloHUD.hideLoadingHud()
                        self.contentCreationFailed(error.elloErrorMessage ?? error.localizedDescription)
                    }
                )
            }
            else {
                ElloHUD.hideLoadingHud()
                contentCreationFailed(NSLocalizedString("No content was submitted", comment: "No content was submitted"))
            }
        }
        else {
            contentCreationFailed(NSLocalizedString("No content was submitted", comment: "No content was submitted"))
        }
    }

    private func emitCommentSuccess(comment: Comment) {
        postNotification(CommentChangedNotification, (comment, .Create))
        if let post = comment.parentPost, let count = post.commentsCount {
            post.commentsCount = count + 1
            postNotification(PostChangedNotification, (post, .Update))
        }

        if let listener = commentSuccessListener {
            listener(comment: comment)
        }
        Tracker.sharedTracker.contentCreated(.Comment)
    }

    private func emitPostSuccess(post: Post) {
        if let user = currentUser, let count = user.postsCount {
            user.postsCount = count + 1
            postNotification(CurrentUserChangedNotification, user)
        }
        postNotification(PostChangedNotification, (post, .Create))
        Tracker.sharedTracker.contentCreated(.Post)
        if let listener = postSuccessListener {
            listener(post: post)
        }
        else {
            goToPreviousTab()
            self.screen.reportSuccess(NSLocalizedString("Post successfully created!", comment: "Post successfully created!"))
        }
    }

    private func goToPreviousTab() {
        elloTabBarController?.selectedTab = previousTab
    }

    func contentCreationFailed(errorMessage: String) {
        let contentType: ContentType = (parentPost == nil) ? .Post : .Comment
        Tracker.sharedTracker.contentCreationFailed(contentType, message: errorMessage)
        screen.reportError("Could not create \(contentType.rawValue)", errorMessage: errorMessage)
    }

    public func omnibarPresentController(controller: UIViewController) {
        if !(controller is AlertViewController) {
            UIApplication.sharedApplication().statusBarStyle = .Default
        }
        self.presentViewController(controller, animated: true, completion: nil)
    }

    public func omnibarPushController(controller: UIViewController) {
        self.navigationController?.pushViewController(controller, animated: true)
    }

    public func omnibarDismissController(controller: UIViewController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}


public class OmnibarData : NSObject, NSCoding {
    public let attributedText: NSAttributedString?
    public let image: UIImage?

    required public init(attributedText: NSAttributedString?, image: UIImage?) {
        self.attributedText = attributedText
        self.image = image
        super.init()
    }

// MARK: NSCoding

    public func encodeWithCoder(encoder: NSCoder) {
        if let attributedText = attributedText {
            encoder.encodeObject(attributedText, forKey: "attributedText")
        }

        if let image = image {
            encoder.encodeObject(image, forKey: "image")
        }
    }

    required public init(coder aDecoder: NSCoder) {
        let decoder = Coder(aDecoder)
        attributedText = decoder.decodeOptionalKey("attributedText")
        image = decoder.decodeOptionalKey("image")
        super.init()
    }

}

extension OmnibarViewController {

    // OK:
    //   - one text region
    //   - one image region
    //   - one image region, followed by one text region
    // NOT OK:
    //   - all other cases
    public class func canEditPost(post: Post) -> Bool {
        if let regions = post.content {
            var hasTextRegion = false
            var hasImageRegion = false

            for region in regions {
                if region is TextRegion {
                    if hasTextRegion { return false }
                    hasTextRegion = true
                }
                else if region is ImageRegion {
                    if hasImageRegion || hasTextRegion { return false }
                    hasImageRegion = true
                }
                else {
                    return false
                }
            }

            return hasTextRegion || hasImageRegion
        }
        return false
    }
}
