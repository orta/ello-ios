//
//  OmnibarViewController.swift
//  Ello
//
//  Created by Sean on 1/15/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit


class OmnibarViewController: BaseElloViewController, OmnibarScreenDelegate {
    var keyboardWillShowObserver: NotificationObserver?
    var keyboardWillHideObserver: NotificationObserver?

    var parentPost: Post?

    typealias PostSuccessListener = (post : Post)->()
    typealias CommentSuccessListener = (comment : Comment)->()
    var postSuccessListeners = [PostSuccessListener]()
    var commentSuccessListeners = [CommentSuccessListener]()

    convenience init(parentPost post: Post) {
        self.init(nibName: nil, bundle: nil)
        parentPost = post
    }

    func omnibarDataName() -> String {
        if let post = parentPost {
            return "omnibar_comment_\(post.postId)"
        }
        else {
            return "omnibar_post"
        }
    }

    func onPostSuccess(block: PostSuccessListener) {
        postSuccessListeners.append(block)
    }
    func onCommentSuccess(block: CommentSuccessListener) {
        commentSuccessListeners.append(block)
    }

    override func loadView() {
        var screen = OmnibarScreen(frame: UIScreen.mainScreen().bounds)
        self.view = screen
        screen.hasParentPost = parentPost != nil
    }

    // the _mockScreen is only for testing - otherwise `self.screen` is always
    // just an appropriately typed accessor for `self.view`
    var _mockScreen: OmnibarScreenProtocol?
    var screen: OmnibarScreenProtocol {
        set(screen) { _mockScreen = screen }
        get { return _mockScreen ?? self.view as OmnibarScreen }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        let fileName = omnibarDataName()
        if let data : NSData = Tmp.read(fileName) {
            if let omnibarData = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? OmnibarData {
                self.screen.attributedText = omnibarData.attributedText
                self.screen.image = omnibarData.image
            }
            Tmp.remove(fileName)
        }

        self.screen.delegate = self

        keyboardWillShowObserver = NotificationObserver(notification: Keyboard.Notifications.KeyboardWillShow, block: self.willShow)
        keyboardWillHideObserver = NotificationObserver(notification: Keyboard.Notifications.KeyboardWillHide, block: self.willHide)
    }

    override func viewWillDisappear(animated: Bool) {
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
        self.screen.avatarURL = currentUser?.avatarURL
    }

    func omnibarCancel() {
        if let post = parentPost {
            let omnibarData = OmnibarData(attributedText: screen.attributedText, image: screen.image)
            let data = NSKeyedArchiver.archivedDataWithRootObject(omnibarData)
            Tmp.write(data, to: omnibarDataName())
        }

        self.navigationController?.popViewControllerAnimated(true)
    }

    func omnibarSubmitted(text: NSAttributedString?, image: UIImage?) {
        var content = [AnyObject]()
        if let text = text?.string {
            if countElements(text) > 0 {
                content.append(text)
            }
        }

        if let image = image {
            content.append(image)
        }

        var service : PostEditingService
        if let parentPost = parentPost {
            service = PostEditingService(parentPost: parentPost)
        }
        else {
            service = PostEditingService()
        }

        if countElements(content) > 0 {
            ElloHUD.showLoadingHud()
            service.create(content: content, success: { postOrComment in
                ElloHUD.hideLoadingHud()
                Tmp.remove(self.omnibarDataName())

                if let parentPost = self.parentPost {
                    var comment = postOrComment as Comment
                    for listener in self.commentSuccessListeners {
                        listener(comment: comment)
                    }
                }
                else {
                    var post = postOrComment as Post
                    for listener in self.postSuccessListeners {
                        listener(post: post)
                    }
                    self.screen.reportSuccess("Post successfully created!")
                }
            }, failure: { error, statusCode in
                ElloHUD.hideLoadingHud()
                self.screen.reportError("Could not create post", error: error)
            })
        }
        else {
            self.screen.reportError("Could not create post", error: "No content was submitted")
        }
    }

    func omnibarPresentController(controller: UIViewController) {
        self.presentViewController(controller, animated: true, completion: nil)
    }

    func omnibarDismissController(controller: UIViewController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}


class OmnibarData : NSObject, NSCoding {
    let attributedText: NSAttributedString?
    let image: UIImage?

    required init(attributedText: NSAttributedString?, image: UIImage?) {
        super.init()
        self.attributedText = attributedText
        self.image = image
    }

// MARK: NSCoding

    func encodeWithCoder(encoder: NSCoder) {
        if let attributedText = self.attributedText {
            encoder.encodeObject(attributedText, forKey: "attributedText")
        }

        if let image = self.image {
            encoder.encodeObject(image, forKey: "image")
        }
    }

    required init(coder decoder: NSCoder) {
        self.attributedText = decoder.decodeObjectForKey("attributedText") as? NSAttributedString
        self.image = decoder.decodeObjectForKey("image") as? UIImage
    }

}
