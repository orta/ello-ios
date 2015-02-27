//
//  OmnibarScreen.swift
//  Ello
//
//  Created by Colin Gray on 2/26/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit


@objc
protocol OmnibarScreenDelegate {
    func omnibarCanceled()
    func omnibarSubmitted()
}


class OmnibarScreen : UIView {
    struct Size {
        static let margins = CGFloat(10)
        static let textMargins = CGFloat(10)
        static let labelCorrection = CGFloat(8.5)
        static let innerTextMargin = CGFloat(11)
        static let bottomTextMargin = CGFloat(1)
        static let toolbarHeight = CGFloat(60)
        static let buttonWidth = CGFloat(70)
        static let buttonRightMargin = CGFloat(5)
    }

    weak var delegate : OmnibarScreenDelegate?

    var scrollView : UIScrollView!

    var avatarView : UIImageView!
    var cameraButton : UIButton!
    var cancelButton : UIButton!
    var submitButton : UIButton!
    var buttonContainer : ElloEquallySpacedLayout!

    var sayElloOverlay : UIControl!
    var sayElloLabel : UILabel!

    var textContainer : UIView!
    var textView : UITextView!

    override init(frame: CGRect) {
        scrollView = UIScrollView()
        scrollView.backgroundColor = UIColor.whiteColor()

        avatarView = UIImageView(frame: CGRectZero)
        avatarView.backgroundColor = UIColor.blackColor()
        avatarView.clipsToBounds = true

        textContainer = UIView()
        textContainer.backgroundColor = UIColor.greyE5()
        buttonContainer = ElloEquallySpacedLayout()

        sayElloOverlay = UIControl()
        sayElloLabel = UILabel()
        sayElloLabel.text = "Say Ello…"
        sayElloLabel.textColor = UIColor.greyA()
        sayElloLabel.font = UIFont.typewriterFont(12)

        cameraButton = UIButton()
        cameraButton.setImage(ElloDrawable.imageOfCameraIcon, forState: .Normal)
        cameraButton.setImage(ElloDrawable.imageOfCameraIconSelected, forState: .Selected)

        cancelButton = UIButton()
        cancelButton.setImage(ElloDrawable.imageOfCancelIcon, forState: .Normal)
        cancelButton.setImage(ElloDrawable.imageOfCancelIconSelected, forState: .Selected)

        submitButton = UIButton()
        submitButton.setImage(ElloDrawable.imageOfSubmitIcon, forState: .Normal)
        submitButton.setImage(ElloDrawable.imageOfSubmitIconSelected, forState: .Selected)

        textView = UITextView()
        textView.textColor = UIColor.blackColor()
        textView.font = UIFont.typewriterFont(12)
        textView.textContainer.lineFragmentPadding = 0
        textView.backgroundColor = UIColor.greyE5()

        super.init(frame: frame)

        self.addSubview(scrollView)
        for view in [avatarView, buttonContainer, textContainer, sayElloOverlay] as [UIView] {
            scrollView.addSubview(view)
        }

        for view in [cameraButton, cancelButton, submitButton] as [UIView] {
            buttonContainer.addSubview(view)
        }
        cancelButton.addTarget(self, action: Selector("cancelEditing"), forControlEvents: .TouchUpInside)

        sayElloOverlay.addSubview(sayElloLabel)
        sayElloOverlay.addTarget(self, action: Selector("startEditing"), forControlEvents: .TouchUpInside)

        textView.autoresizingMask = .FlexibleHeight | .FlexibleWidth
        textContainer.addSubview(textView)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        scrollView.frame = self.bounds
        avatarView.frame = CGRect(x: Size.margins, y: Size.margins, width: Size.toolbarHeight, height: Size.toolbarHeight)
        avatarView.layer.cornerRadius = Size.toolbarHeight / CGFloat(2)

        let buttonContainerWidth = Size.buttonWidth * CGFloat(buttonContainer.subviews.count)
        buttonContainer.frame = CGRect(x: self.bounds.width - Size.buttonRightMargin, y: Size.margins, width: 0, height: Size.toolbarHeight)
            .growLeft(buttonContainerWidth)

        let kbdHeight = Keyboard.shared().height
        let bottom = self.convertPoint(CGPoint(x: 0, y: self.bounds.height), toView: self.window!).y
        let bottomHeight = self.window!.frame.height - bottom
        var localKbdHeight = kbdHeight - bottomHeight
        if localKbdHeight < 0 {
            localKbdHeight = 0
        }
        else {
            localKbdHeight += Size.bottomTextMargin
        }
        textContainer.frame = CGRect.make(x: Size.margins, y: avatarView.frame.maxY + Size.innerTextMargin,
            right: self.bounds.size.width - Size.margins, bottom: self.bounds.size.height - localKbdHeight)
        sayElloOverlay.frame = textContainer.frame
        sayElloLabel.frame = CGRect(x: Size.textMargins, y: Size.textMargins + Size.labelCorrection, width: 0, height: 0)
        sayElloLabel.sizeToFit()

        textView.frame = textContainer.bounds.inset(all: Size.textMargins)

        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: textContainer.frame.maxY)
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: localKbdHeight, right: 0)
        scrollView.contentInset = insets
        scrollView.scrollIndicatorInsets = insets
    }

    func keyboardWillShow() {
        self.setNeedsLayout()
        UIView.animateWithDuration(Keyboard.shared().duration,
            delay: 0.0,
            options: Keyboard.shared().options,
            animations: {
                self.layoutIfNeeded()
        },
        completion: nil)
    }

    func keyboardWillHide() {
        self.setNeedsLayout()
        UIView.animateWithDuration(Keyboard.shared().duration,
            delay: 0.0,
            options: Keyboard.shared().options,
            animations: {
                self.layoutIfNeeded()
            },
            completion: nil)
    }

    var avatarURL : NSURL? {
        willSet(newValue) {
            if self.avatarURL != newValue {
                if let avatarURL = newValue {
                    self.avatarView.sd_setImageWithURL(avatarURL)
                }
                else {
                    // TODO: Ello default
                    self.avatarView.image = nil
                }
            }
        }
    }

    func startEditing() {
        sayElloOverlay.hidden = true
        textView.becomeFirstResponder()
    }

    func cancelEditing() {
        sayElloOverlay.hidden = false
        textView.text = ""
        textView.resignFirstResponder()
    }

}
