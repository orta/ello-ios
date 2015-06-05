//
//  OmnibarViewController.swift
//  Ello
//
//  Created by Sean on 1/15/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit


public class OmnibarViewController: BaseElloViewController, OmnibarScreenDelegate {
    var keyboardWillShowObserver: NotificationObserver?
    var keyboardWillHideObserver: NotificationObserver?

    override public var tabBarItem: UITabBarItem? {
        get { return UITabBarItem.svgItem("omni") }
        set { self.tabBarItem = newValue }
    }

    var previousTab: ElloTab = .DefaultTab
    var parentPost: Post?
    var defaultText: String?

    typealias CommentSuccessListener = (comment : Comment) -> Void
    var commentSuccessListeners = [CommentSuccessListener]()

    var _mockScreen: OmnibarScreenProtocol?
    public var screen: OmnibarScreenProtocol {
        set(screen) { _mockScreen = screen }
        get { return _mockScreen ?? self.view as! OmnibarScreen }
    }

    convenience public init(parentPost post: Post) {
        self.init(nibName: nil, bundle: nil)
        parentPost = post
    }

    convenience public init(parentPost post: Post, defaultText: String) {
        self.init(parentPost: post)
        self.defaultText = defaultText
    }

    public func omnibarDataName() -> String {
        if let post = parentPost {
            return "omnibar_comment_\(post.id)"
        }
        else {
            return "omnibar_post"
        }
    }

    func onCommentSuccess(listener: CommentSuccessListener) {
        commentSuccessListeners.append(listener)
    }

    override public func loadView() {
        var screen = OmnibarScreen(frame: UIScreen.mainScreen().bounds)
        self.view = screen

        screen.hasParentPost = parentPost != nil
        screen.currentUser = currentUser
        screen.text = self.defaultText

        let fileName = omnibarDataName()
        if let data : NSData = Tmp.read(fileName) {
            if let omnibarData = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? OmnibarData {
                self.screen.attributedText = omnibarData.attributedText
                self.screen.image = omnibarData.image
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
    }

    override public func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .None)
        UIApplication.sharedApplication().statusBarStyle = .LightContent

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
        if let post = parentPost {
            let omnibarData = OmnibarData(attributedText: screen.attributedText, image: screen.image)
            let data = NSKeyedArchiver.archivedDataWithRootObject(omnibarData)
            Tmp.write(data, to: omnibarDataName())
            Tracker.sharedTracker.contentCreationCanceled(.Comment)
            navigationController?.popViewControllerAnimated(true)
        }
        else {
            Tracker.sharedTracker.contentCreationCanceled(.Post)
            goToPreviousTab()
        }
    }

    public func omnibarSubmitted(text: NSAttributedString?, image: UIImage?) {
        var content = [AnyObject]()
        if let text = text?.string {
            let alphanum = NSCharacterSet.alphanumericCharacterSet()
            if (count(text) > 0 && text.rangeOfCharacterFromSet(alphanum) != nil) {
                content.append(text)
            }
        }

        if let image = image {
            content.append(image)
        }

        let service : PostEditingService
        if let parentPost = parentPost {
            service = PostEditingService(parentPost: parentPost)
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
        for listener in self.commentSuccessListeners {
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
        goToPreviousTab()
        self.screen.reportSuccess(NSLocalizedString("Post successfully created!", comment: "Post successfully created!"))
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
    let attributedText: NSAttributedString?
    let image: UIImage?

    required public init(attributedText: NSAttributedString?, image: UIImage?) {
        self.attributedText = attributedText
        self.image = image
        super.init()
    }

// MARK: NSCoding

    public func encodeWithCoder(encoder: NSCoder) {
        if let attributedText = self.attributedText {
            encoder.encodeObject(attributedText, forKey: "attributedText")
        }

        if let image = self.image {
            encoder.encodeObject(image, forKey: "image")
        }
    }

    required public init(coder aDecoder: NSCoder) {
        let decoder = Coder(aDecoder)
        self.attributedText = decoder.decodeOptionalKey("attributedText")
        self.image = decoder.decodeOptionalKey("image")
    }

}
