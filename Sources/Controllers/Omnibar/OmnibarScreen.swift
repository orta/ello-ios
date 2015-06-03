//
//  OmnibarScreen.swift
//  Ello
//
//  Created by Colin Gray on 2/26/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//
// This screen tracks two sets of "changes": the attributed text of the textView
// (`currentText : NSAttributedString`), and the image uploaded by the image
// picker (`currentImage`).  Both have a corresponding 'undo' state (`undoText` and
// `undoImage`).
//
// When the cancel button is tapped, the editor is reset and they keyboard is
// dismissed, but if the text or image was set, they go into `undoText` and
// `undoImage`, and the cancel button changes to the "undo" icon.  The logic for
// when the button is undo vs cancel is stored in `canUndo()`.  To update the
// button state, call `updateUndoState()`.
//
// Lots of views and actions are exposed, this is for testing.
//
// In layoutSubviews(), the avatar, buttons, and text editor are placed
// according to the keyboard state (using the custom Keyboard class to get the
// height and animation properties).
//
// The events that are sent back to the controller: presenting and dismissing
// the UIImagePickerController, and submitting the text and image.

import UIKit
import MobileCoreServices
import FLAnimatedImage
import SVGKit

@objc
public protocol OmnibarScreenDelegate {
    func omnibarCancel()
    func omnibarPushController(controller: UIViewController)
    func omnibarPresentController(controller : UIViewController)
    func omnibarDismissController(controller : UIViewController)
    func omnibarSubmitted(text : NSAttributedString?, image: UIImage?)
}


@objc
public protocol OmnibarScreenProtocol {
    var delegate : OmnibarScreenDelegate? { get set }
    var avatarURL : NSURL? { get set }
    var avatarImage : UIImage? { get set }
    var currentUser : User? { get set }
    var hasParentPost : Bool { get set }
    var text : String? { get set }
    var image : UIImage? { get set }
    var attributedText : NSAttributedString? { get set }
    func reportSuccess(title : String)
    func reportError(title : String, error : NSError)
    func reportError(title : String, errorMessage : String)
    func keyboardWillShow()
    func keyboardWillHide()
    func startEditing()
}


public class OmnibarScreen : UIView, OmnibarScreenProtocol, UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    struct Size {
        static let margins = CGFloat(10)
        static let textMargins = UIEdgeInsets(top: 22, left: 30, bottom: 9, right: 30)
        static let labelCorrection = CGFloat(8.5)
        static let innerTextMargin = CGFloat(11)
        static let bottomTextMargin = CGFloat(1)
        static let toolbarHeight = CGFloat(60)
        static let buttonWidth = CGFloat(70)
        static let buttonRightMargin = CGFloat(5)
    }

// MARK: public access to text and image

    // Styles the text and assigns it as an NSAttributedString to
    // `attributedText`
    public var text : String? {
        set(newValue) {
            if let value = newValue {
                self.attributedText = ElloAttributedString.style(value)
            }
            else {
                self.attributedText = nil
            }
        }
        get {
            return attributedText?.string
        }
    }

    // assigns the NSAttributedString to the UITextView and assigns
    // `currentText`
    public var attributedText : NSAttributedString? {
        set(newValue) {
            userSetCurrentText(newValue)
        }
        get {
            return currentText
        }
    }

    public var image : UIImage? {
        set(newValue) {
            userSetCurrentImage(newValue)
        }
        get {
            return currentImage
        }
    }

    public var avatarURL : NSURL? {
        willSet(newValue) {
            if avatarURL != newValue {
                if let avatarURL = newValue {
                    self.avatarButtonView.sd_setImageWithURL(avatarURL, forState: .Normal)
                }
                else {
                    self.avatarButtonView.setImage(nil, forState: .Normal)
                }
            }
        }
    }

    public var avatarImage : UIImage? {
        willSet(newValue) {
            if avatarImage != newValue {
                if let avatarImage = newValue {
                    self.avatarButtonView.setImage(avatarImage, forState: .Normal)
                }
                else {
                    self.avatarButtonView.setImage(nil, forState: .Normal)
                }
            }
        }
    }

    public var hasParentPost : Bool = false {
        didSet {
            setNeedsLayout()
        }
    }

    public var currentUser: User?

// MARK: internal and/or private vars

    weak public var delegate : OmnibarScreenDelegate?

    public let avatarButtonView = UIButton()
    public let cameraButton = UIButton()

    public let imageSelectedButton = UIButton()
    let imageSelectedOverlay = FLAnimatedImageView()
    let navigationBar = ElloNavigationBar(frame: CGRectZero)
    let cancelButton = UIButton()
    let submitButton = UIButton()
    public let buttonContainer = ElloEquallySpacedLayout()

    public let sayElloOverlay = UIControl()
    let sayElloLabel = UILabel()

    let textContainer = UIView()
    public let textView = UITextView()

    private var currentText : NSAttributedString?
    private var currentImage : UIImage?

    private var undoText : NSAttributedString?
    private var undoImage : UIImage?

// MARK: init

    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.whiteColor()

        setupAvatarView()
        setupSayElloViews()
        setupImageSelectedViews()
        setupNavigationBar()
        setupToolbarButtons()
        setupTextViews()
        setupViewHierarchy()
        setupSwipeGesture()
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

// MARK: View setup code

    // Avatar view (in the upper right corner) just needs to round its corners,
    // which is done in layoutSubviews.
    private func setupAvatarView() {
        avatarButtonView.backgroundColor = UIColor.blackColor()
        avatarButtonView.clipsToBounds = true
        avatarButtonView.addTarget(self, action: Selector("profileImageTapped"), forControlEvents: .TouchUpInside)
    }

    // the label and overlay cover the text view; on tap they are hidden and the
    // textView is given first responder status.  This is basically a workaround
    // for UITextView not having a `placeholder` property.
    private func setupSayElloViews() {
        sayElloLabel.text = "Say Ello…"
        sayElloLabel.textColor = UIColor.greyA()
        sayElloLabel.font = UIFont.typewriterFont(12)

        sayElloOverlay.addTarget(self, action: Selector("startEditingAction"), forControlEvents: .TouchUpInside)
    }
    // This is the button, image, and icon that appear in lieu of the camera
    // button after an image is selected.  Tapping this button removes the
    // selected image.
    private func setupImageSelectedViews() {
        // this rect will be adjusted by ElloEquallySpacedLayout, but I need it
        // set to *something* so that autoresizingMask is calculated correctly
        imageSelectedButton.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
        imageSelectedButton.contentMode = .ScaleAspectFit
        imageSelectedButton.addTarget(self, action: Selector("removeButtonAction"), forControlEvents: .TouchUpInside)

        imageSelectedOverlay.contentMode = .Center
        imageSelectedOverlay.layer.cornerRadius = 13
        imageSelectedOverlay.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.7)
        imageSelectedOverlay.image = SVGKImage(named: "trash_white.svg").UIImage!
        imageSelectedOverlay.frame = CGRect.at(x: imageSelectedButton.frame.width / 2, y: imageSelectedButton.frame.height / 2).grow(all: imageSelectedOverlay.layer.cornerRadius)
        imageSelectedOverlay.autoresizingMask = .FlexibleBottomMargin | .FlexibleTopMargin | .FlexibleLeftMargin | .FlexibleRightMargin
        imageSelectedButton.addSubview(imageSelectedOverlay)
    }
    private func setupNavigationBar() {
        let backItem = UIBarButtonItem.backChevronWithTarget(self, action: Selector("backAction"))
        let item = UINavigationItem()
        item.leftBarButtonItem = backItem
        item.title = NSLocalizedString("Leave a comment", comment: "leave a comment")
        item.fixNavBarItemPadding()
        self.navigationBar.items = [item]
    }
    // buttons that make up the "toolbar"
    private func setupToolbarButtons() {
        cameraButton.setSVGImages("camera")
        cameraButton.addTarget(self, action: Selector("addImageAction"), forControlEvents: .TouchUpInside)

        cancelButton.setSVGImages("x")
        cancelButton.addTarget(self, action: Selector("cancelEditingAction"), forControlEvents: .TouchUpInside)

        submitButton.setSVGImages("arrow")
        submitButton.addTarget(self, action: Selector("submitAction"), forControlEvents: .TouchUpInside)
    }
    // The textContainer is the outetr gray background.  The text view is
    // configured to fill that container (only the container and the text view
    // insets are modified in layoutSubviews)
    private func setupTextViews() {
        textContainer.backgroundColor = UIColor.greyE5()
        textView.editable = true
        textView.allowsEditingTextAttributes = false  // TEMP
        textView.selectable = true
        textView.textColor = UIColor.blackColor()
        textView.font = UIFont.typewriterFont(12)
        textView.textContainer.lineFragmentPadding = 0
        textView.backgroundColor = UIColor.greyE5()
        textView.delegate = self
        textView.autoresizingMask = .FlexibleHeight | .FlexibleWidth
    }
    private func setupViewHierarchy() {
        for view in [navigationBar, avatarButtonView, buttonContainer, textContainer, sayElloOverlay] as [UIView] {
            self.addSubview(view)
        }
        for view in [cameraButton, cancelButton, submitButton] as [UIView] {
            buttonContainer.addSubview(view)
        }
        sayElloOverlay.addSubview(sayElloLabel)
        textContainer.addSubview(textView)
    }
    private func setupSwipeGesture() {
        let gesture = UISwipeGestureRecognizer()
        gesture.direction = .Down
        gesture.addTarget(self, action: Selector("swipedDown"))
        self.addGestureRecognizer(gesture)
    }

// MARK: Public interface

    public func reportSuccess(title : String) {
        let alertController = AlertViewController(message: title)

        let cancelAction = AlertAction(title: NSLocalizedString("OK", comment: "ok button"), style: .Light, handler: .None)
        alertController.addAction(cancelAction)

        delegate?.omnibarPresentController(alertController)
        self.resetAfterSuccessfulPost()
    }

    private func resetAfterSuccessfulPost() {
        resetUndoState()
        resetEditor()
    }

    public func profileImageTapped() {
        if let userParam = currentUser?.id {
            let profileVC = ProfileViewController(userParam: userParam)
            profileVC.currentUser = self.currentUser
            self.delegate?.omnibarPushController(profileVC)
        }
    }

    public func startEditing() {
        sayElloOverlay.hidden = true
        textView.becomeFirstResponder()
    }

    public func reportError(title : String, error : NSError) {
        let errorMessage = error.elloErrorMessage ?? error.localizedDescription
        reportError(title, errorMessage: errorMessage)
    }

    public func reportError(title : String, errorMessage : String) {
        let alertController = AlertViewController(message: title)

        let cancelAction = AlertAction(title: NSLocalizedString("OK", comment: "ok button"), style: .Light, handler: .None)
        alertController.addAction(cancelAction)

        delegate?.omnibarPresentController(alertController)
    }

// MARK: Keyboard events - animate layout update in conjunction with keyboard animation

    public func keyboardWillShow() {
        self.setNeedsLayout()
        UIView.animateWithDuration(Keyboard.shared().duration,
            delay: 0.0,
            options: Keyboard.shared().options,
            animations: {
                self.layoutIfNeeded()
            },
            completion: nil)
    }

    public func keyboardWillHide() {
        self.setNeedsLayout()
        UIView.animateWithDuration(Keyboard.shared().duration,
            delay: 0.0,
            options: Keyboard.shared().options,
            animations: {
                self.layoutIfNeeded()
            },
            completion: nil)
    }

    private func resignKeyboard() {
        if text == nil || text! == "" {
            sayElloOverlay.hidden = false
        }
        textView.resignFirstResponder()
    }

// MARK: Layout and update views

    override public func layoutSubviews() {
        super.layoutSubviews()

        var screenTop = CGFloat(0)
        if hasParentPost {
            navigationBar.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: ElloNavigationBar.Size.height)
            screenTop += navigationBar.frame.height
        }

        var avatarViewLeft = Size.margins
        avatarButtonView.frame = CGRect(x: avatarViewLeft, y: screenTop + Size.margins, width: Size.toolbarHeight, height: Size.toolbarHeight)
        avatarButtonView.layer.cornerRadius = Size.toolbarHeight / CGFloat(2)

        let buttonContainerWidth = Size.buttonWidth * CGFloat(buttonContainer.subviews.count)
        buttonContainer.spacing = (buttonContainerWidth - buttonContainer.frame.height * CGFloat(buttonContainer.subviews.count)) / CGFloat(buttonContainer.subviews.count - 1)
        if buttonContainer.spacing < 0 {
            buttonContainer.spacing = 0
        }
        buttonContainer.frame = CGRect(x: self.frame.width - Size.buttonRightMargin, y: screenTop + Size.margins, width: 0, height: Size.toolbarHeight)
            .growLeft(buttonContainerWidth)

        // make sure the textContainer is above the keboard, with a 1pt line
        // margin at the bottom.
        // size the textContainer and sayElloOverlay to be identical.
        var localKbdHeight = Keyboard.shared().keyboardBottomInset(inView: self)
        if localKbdHeight < 0 {
            localKbdHeight = Size.margins
        }
        else {
            localKbdHeight += Size.bottomTextMargin
        }
        textContainer.frame = CGRect.make(x: Size.margins, y: buttonContainer.frame.maxY + Size.innerTextMargin,
            right: self.bounds.size.width - Size.margins, bottom: self.bounds.size.height - localKbdHeight)
        sayElloOverlay.frame = textContainer.frame
        sayElloLabel.frame = CGRect(x: Size.textMargins.left, y: Size.textMargins.top + Size.labelCorrection, width: 0, height: 0)
        sayElloLabel.sizeToFit()

        // size so that it is offset from the textContainer
        textView.frame = textContainer.bounds.inset(top: 0, left: Size.textMargins.left, bottom: 0, right: Size.textMargins.right)
        textView.contentInset = UIEdgeInsets(top: Size.textMargins.top, left: 0, bottom: Size.textMargins.bottom, right: 0)
        textView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -Size.textMargins.right)
        textContainer.clipsToBounds = true
        textView.clipsToBounds = false
    }

    private func resetEditor() {
        sayElloOverlay.hidden = false
        textView.resignFirstResponder()
        textView.text = ""
        currentText = nil
        setCurrentImage(nil)
        updateUndoState()
    }

    private func updateUndoState() {
        if canUndo() {
            cancelButton.setSVGImages("reply")
            cancelButton.removeTarget(self, action: Selector("cancelEditingAction"), forControlEvents: .TouchUpInside)
            cancelButton.addTarget(self, action: Selector("undoCancelAction"), forControlEvents: .TouchUpInside)
        }
        else {
            cancelButton.setSVGImages("x")
            cancelButton.removeTarget(self, action: Selector("undoCancelAction"), forControlEvents: .TouchUpInside)
            cancelButton.addTarget(self, action: Selector("cancelEditingAction"), forControlEvents: .TouchUpInside)
        }
    }

// MARK: Button Actions

    func backAction() {
        self.delegate?.omnibarCancel()
    }

    public func startEditingAction() {
        startEditing()
    }

    public func cancelEditingAction() {
        takeUndoSnapshot()
        resetEditor()
    }

    public func undoCancelAction() {
        currentText = undoText
        textView.attributedText = undoText
        setCurrentImage(undoImage)
        if currentTextIsPresent() {
            startEditingAction()
        }

        resetUndoState()
    }

    public func submitAction() {
        if currentTextIsPresent() || currentImageIsPresent() {
            textView.resignFirstResponder()
            var submittedText : NSAttributedString?
            if currentTextIsPresent() {
                submittedText = currentText
            }
            delegate?.omnibarSubmitted(submittedText, image: currentImage)
        }
    }

    public func removeButtonAction() {
        userSetCurrentImage(nil)
    }

    public func swipedDown() {
        resignKeyboard()
    }

// MARK: Undo logic

    private func currentTextIsPresent() -> Bool {
        return currentText != nil && count(currentText!.string) > 0
    }

    private func currentImageIsPresent() -> Bool {
        return currentImage != nil
    }

    private func undoTextIsPresent() -> Bool {
        return undoText != nil && count(undoText!.string) > 0
    }

    private func undoImageIsPresent() -> Bool {
        return undoImage != nil
    }

    private func resetUndoState() {
        undoText = nil
        undoImage = nil
        updateUndoState()
    }

    public func canUndo() -> Bool {
        if currentTextIsPresent() || currentImageIsPresent() {
            return false
        }

        if undoTextIsPresent() || undoImageIsPresent() {
            return true
        }

        return false
    }

    private func takeUndoSnapshot() {
        undoText = currentText
        undoImage = currentImage
    }

// MARK: Images

    // this action has side effects; disabling undo for example
    func userSetCurrentImage(image : UIImage?) {
        undoImage = nil
        setCurrentImage(image)
        updateUndoState()
    }

    // this updates the currentImage and buttons, but doesn't mess with undo
    private func setCurrentImage(image : UIImage?) {
        self.currentImage = image

        if let image = image {
            cameraButton.removeFromSuperview()
            imageSelectedButton.setImage(image, forState: .Normal)
            if let imageSelectedImageView = imageSelectedButton.imageView {
                imageSelectedImageView.contentMode = .ScaleAspectFill
                imageSelectedImageView.clipsToBounds = true
            }
            buttonContainer.insertSubview(imageSelectedButton, atIndex: 0)
            buttonContainer.layoutIfNeeded()

            self.imageSelectedButton.transform = CGAffineTransformMakeScale(1.3, 1.3)
            imageSelectedButton.alpha = 0
            UIView.animateWithDuration(0.3) {
                self.imageSelectedButton.transform = CGAffineTransformIdentity
            }
            UIView.animateWithDuration(0.2) {
                self.imageSelectedButton.alpha = 1
            }
        }
        else {
            if imageSelectedButton.superview != nil {
                imageSelectedButton.removeFromSuperview()
                let convertedFrame = convertRect(imageSelectedButton.frame, fromView: buttonContainer)
                imageSelectedButton.frame = convertedFrame
                addSubview(imageSelectedButton)
                UIView.animateWithDuration(0.3) {
                    self.imageSelectedButton.transform = CGAffineTransformMakeScale(0.1, 0.1)
                }
                UIView.animateWithDuration(0.2) {
                    self.imageSelectedButton.alpha = 0
                }
            }
            buttonContainer.insertSubview(cameraButton, atIndex: 0)
        }

        // disable the cancel button during animations (fixes weird scaling bug in iOS 8)
        cancelButton.userInteractionEnabled = false
        delay(0.3) {
            self.cancelButton.userInteractionEnabled = true
        }
    }

// MARK: Camera / Image Picker

    public func addImageAction() {
        let alert = UIImagePickerController.alertControllerForImagePicker(openImagePicker)
        alert.map { self.delegate?.omnibarPresentController($0) }
    }

    private func openImagePicker(imageController : UIImagePickerController) {
        imageController.delegate = self
        delegate?.omnibarPresentController(imageController)
    }

    public func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
    }

    public func imagePickerController(controller: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            image.copyWithCorrectOrientationAndSize() { image in
                self.userSetCurrentImage(image)
                self.delegate?.omnibarDismissController(controller)
            }
        }
        else {
            delegate?.omnibarDismissController(controller)
        }
    }

    public func imagePickerControllerDidCancel(controller: UIImagePickerController) {
        delegate?.omnibarDismissController(controller)
    }

// MARK: Text View editing

    // Removes the undo state, and updates the text view, including the overlay
    // and first responder state.  This method is meant to be used during
    // initialization.
    private func userSetCurrentText(value : NSAttributedString?) {
        if currentText != value {
            if let text = value {
                textView.attributedText = text
                sayElloOverlay.hidden = true
            }
            else {
                textView.text = ""
                sayElloOverlay.hidden = false
            }
        }

        currentText = value
        textView.resignFirstResponder()
        resetUndoState()
    }

    public func textViewShouldBeginEditing(textView : UITextView) -> Bool {
        return true
    }

    public func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText: String) -> Bool {
        let newText = NSString(string: textView.text).stringByReplacingCharactersInRange(range, withString: replacementText)
        self.currentText = ElloAttributedString.style(newText)

        updateUndoState()

        return true
    }

}
