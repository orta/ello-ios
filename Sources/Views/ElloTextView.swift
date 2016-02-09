//
//  ElloTextView.swift
//  Ello
//
//  Created by Ryan Boyajian on 3/3/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation
import UIKit

protocol ElloTextViewDelegate: NSObjectProtocol {
    func textViewTapped(link: String, object: ElloAttributedObject)
    func textViewTappedDefault()
}

enum ElloAttributedObject {
    case AttributedPost(post: Post)
    case AttributedComment(comment: ElloComment)
    case AttributedUser(user: User)
    case AttributedFollowers(user: User)
    case AttributedFollowing(user: User)
    case AttributedUserId(userId: String)
    case Unknown

    static func generate(link: String, _ object: AnyObject?) -> ElloAttributedObject {
        switch link {
        case "post":
            if let post = object as? Post { return ElloAttributedObject.AttributedPost(post: post) }
        case "comment":
            if let comment = object as? ElloComment { return ElloAttributedObject.AttributedComment(comment: comment) }
        case "user":
            if let user = object as? User { return ElloAttributedObject.AttributedUser(user: user) }
        case "followers":
            if let user = object as? User { return ElloAttributedObject.AttributedFollowers(user: user) }
        case "following":
            if let user = object as? User { return ElloAttributedObject.AttributedFollowing(user: user) }
        case "userId":
            if let userId = object as? String { return ElloAttributedObject.AttributedUserId(userId: userId) }
        default: break
        }
        return .Unknown
    }
}

struct ElloAttributedText {
    static let Link: String = "ElloLinkAttributedString"
    static let Object: String = "ElloObjectAttributedString"
}

class ElloTextView: UITextView {

    var customFont: UIFont?

    weak var textViewDelegate: ElloTextViewDelegate?

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        internalInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        internalInit()
    }

// MARK: Public

    func appendTextWithAction(text: String, link: String? = nil, object: AnyObject? = nil, extraAttrs: [String: AnyObject]? = nil) {
        var attrs = defaultAttrs()
        if let extraAttrs = extraAttrs {
            attrs.merge(extraAttrs)
        }

        if let link = link {
            attrs[ElloAttributedText.Link] = link
            if let object: AnyObject = object {
                attrs[ElloAttributedText.Object] = object
            }
        }
        attributedText = attributedText.append(NSAttributedString(string: text, attributes: attrs))
    }

    func clearText() {
        attributedText = NSAttributedString(string: "")
    }

// MARK: Private

    private func defaultAttrs() -> [String: AnyObject]  {
        return [
            NSFontAttributeName: self.customFont ?? UIFont.defaultFont(),
            NSForegroundColorAttributeName: UIColor.greyA(),
        ]
    }

    private func internalInit() {
        setDefaults()
        addTarget()
    }

    private func setDefaults() {
        // some default styling
        font = UIFont.defaultFont()
        textColor = UIColor.greyA()
        textContainer.lineFragmentPadding = 0
        // makes this like a UILabel
        text = ""
        editable = false
        selectable = false
        scrollEnabled = false
        scrollsToTop = false
        attributedText = NSAttributedString(string: "")
        textContainerInset = UIEdgeInsetsZero
        allowsEditingTextAttributes = false
    }

    private func addTarget() {
        let recognizer = UITapGestureRecognizer(target: self, action: Selector("textViewTapped:"))
        recognizer.numberOfTapsRequired = 1
        recognizer.numberOfTouchesRequired = 1
        addGestureRecognizer(recognizer)
    }

    func textViewTapped(gesture: UITapGestureRecognizer) {
        let location = gesture.locationInView(self)
        if CGRectContainsPoint(self.frame.atOrigin(CGPointZero), location) {
            if let range = characterRangeAtPoint(location) {
                if let pos = closestPositionToPoint(location, withinRange: range) {
                    if let style = textStylingAtPosition(pos, inDirection: .Forward),
                        let link = style[ElloAttributedText.Link] as? String {
                        let object: AnyObject? = style[ElloAttributedText.Object]
                        let attributedObject = ElloAttributedObject.generate(link, object)
                        textViewDelegate?.textViewTapped(link, object: attributedObject)
                        return
                    }
                }
            }

            textViewDelegate?.textViewTappedDefault()
        }
    }
}
