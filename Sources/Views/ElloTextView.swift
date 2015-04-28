//
//  ElloTextView.swift
//  Ello
//
//  Created by Ryan Boyajian on 3/3/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

protocol ElloTextViewDelegate: NSObjectProtocol {
    func textViewTapped(link: String, object: ElloAttributedObject)
}

enum ElloAttributedObject {
    case AttributedPost(post: Post)
    case AttributedComment(comment: Comment)
    case AttributedUser(user: User)
    case AttributedFollowers(user: User)
    case AttributedFollowing(user: User)
    case Unknown

    static func generate(link: String, _ object: AnyObject?) -> ElloAttributedObject {
        switch link {
        case let "post":
            if let post = object as? Post { return ElloAttributedObject.AttributedPost(post: post) }
        case let "comment":
            if let comment = object as? Comment { return ElloAttributedObject.AttributedComment(comment: comment) }
        case let "user":
            if let user = object as? User { return ElloAttributedObject.AttributedUser(user: user) }
        case "followers":
            if let user = object as? User { return ElloAttributedObject.AttributedFollowers(user: user) }
        case "following":
            if let user = object as? User { return ElloAttributedObject.AttributedFollowing(user: user) }
        default: break
        }
        return .Unknown
    }
}

struct ElloAttributedText {
    static let Link : String = "ElloLinkAttributedString"
    static let Object : String = "ElloObjectAttributedString"
}

class ElloTextView: UITextView {

    var customFont: UIFont?

    weak var textViewDelegate: ElloTextViewDelegate?

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        internalInit()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
        internalInit()
    }

// MARK: Public

    func appendTextWithAction(text: String, link: String? = nil, object: AnyObject? = nil, extraAttrs: [NSObject:AnyObject]? = nil) {
        var attrs = defaultAttrs()
        extraAttrs.map(attrs.merge)

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

    private func defaultAttrs() -> [NSObject: AnyObject]  {
        return [
            NSFontAttributeName: self.customFont ?? UIFont.typewriterFont(12),
            NSForegroundColorAttributeName: UIColor.greyA(),
        ]
    }

    private func internalInit() {
        setDefaults()
        addTarget()
    }

    private func setDefaults() {
        // some default styling
        font = UIFont.typewriterFont(12)
        textColor = UIColor.greyA()
        textContainer.lineFragmentPadding = 0
        // makes this like a UILabel
        text = ""
        editable = false
        selectable = false
        scrollEnabled = false
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

    func textViewTapped(gesture : UITapGestureRecognizer) {
        let location = gesture.locationInView(self)
        let range = characterRangeAtPoint(location)
        let pos = closestPositionToPoint(location, withinRange: range)
        let style = textStylingAtPosition(pos, inDirection: .Forward) as! [String : AnyObject]
        if let link = style[ElloAttributedText.Link] as? String {
            let object: AnyObject? = style[ElloAttributedText.Object]
            let attributedObject = ElloAttributedObject.generate(link, object)
            textViewDelegate?.textViewTapped(link, object: attributedObject)
        }
    }
}
