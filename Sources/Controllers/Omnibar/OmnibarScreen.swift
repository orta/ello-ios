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


@objc
protocol OmnibarScreenDelegate {
    func omnibarCancel()
    func omnibarPresentController(controller : UIViewController)
    func omnibarDismissController(controller : UIViewController)
    func omnibarSubmitted(text : NSAttributedString?, image: UIImage?)
}


@objc
protocol OmnibarScreenProtocol {
    var delegate : OmnibarScreenDelegate? { get set }
    var avatarURL : NSURL? { get set }
    var hasParentPost : Bool { get set }
    var text : String? { get set }
    var image : UIImage? { get set }
    var attributedText : NSAttributedString? { get set }
    func reportSuccess(title : String)
    func reportError(title : String, error : NSError)
    func reportError(title : String, error : String)
    func keyboardWillShow()
    func keyboardWillHide()
}


class OmnibarScreen : UIView, OmnibarScreenProtocol, UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    struct Size {
        static let margins = CGFloat(10)
        static let textMargins = CGFloat(9)
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
    var text : String? {
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
    var attributedText : NSAttributedString? {
        set(newValue) {
            userSetCurrentText(newValue)
        }
        get {
            return currentText
        }
    }

    var image : UIImage? {
        set(newValue) {
            userSetCurrentImage(newValue)
        }
        get {
            return currentImage
        }
    }

    var avatarURL : NSURL? {
        willSet(newValue) {
            if avatarURL != newValue {
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

    var hasParentPost : Bool = false {
        didSet {
            backButton.hidden = !hasParentPost
            setNeedsLayout()
        }
    }

// MARK: internal and/or private vars

    weak var delegate : OmnibarScreenDelegate?

    let avatarView = UIImageView()
    let cameraButton = UIButton()

    let imageSelectedButton = UIButton()
    let imageSelectedOverlay = UIImageView()
    let navigationBar = ElloNavigationBar(frame: CGRectZero)
    let backButton = UIButton()
    let cancelButton = UIButton()
    let submitButton = UIButton()
    let buttonContainer = ElloEquallySpacedLayout()

    let sayElloOverlay = UIControl()
    let sayElloLabel = UILabel()

    let textContainer = UIView()
    let textView = UITextView()

    private var currentText : NSAttributedString?
    private var currentImage : UIImage?

    private var undoText : NSAttributedString?
    private var undoImage : UIImage?

// MARK: init

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.whiteColor()

        setupAvatarView()
        setupSayElloViews()
        setupImageSelectedViews()
        setupBackButton()
        setupToolbarButtons()
        setupTextViews()
        setupViewHierarchy()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

// MARK: View setup code

    // Avatar view (in the upper right corner) just needs to round its corners,
    // which is done in layoutSubviews.
    private func setupAvatarView() {
        avatarView.backgroundColor = UIColor.blackColor()
        avatarView.clipsToBounds = true
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
        imageSelectedOverlay.image = ElloDrawable.imageOfTrashIconSelected
        imageSelectedOverlay.frame = CGRect.at(x: imageSelectedButton.frame.width / 2, y: imageSelectedButton.frame.height / 2).grow(all: imageSelectedOverlay.layer.cornerRadius)
        imageSelectedOverlay.autoresizingMask = .FlexibleBottomMargin | .FlexibleTopMargin | .FlexibleLeftMargin | .FlexibleRightMargin
        imageSelectedButton.addSubview(imageSelectedOverlay)
    }
    private func setupBackButton() {
        backButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        let image = UIImage(named: "chevron-back-icon")
        backButton.setImage(image, forState: .Normal)
        backButton.addTarget(self, action: Selector("backAction"), forControlEvents: .TouchUpInside)
    }
    // buttons that make up the "toolbar"
    private func setupToolbarButtons() {
        cameraButton.setImage(ElloDrawable.imageOfCameraIcon, forState: .Normal)
        cameraButton.addTarget(self, action: Selector("addImageAction"), forControlEvents: .TouchUpInside)

        cancelButton.setImage(ElloDrawable.imageOfCancelIcon, forState: .Normal)
        cancelButton.addTarget(self, action: Selector("cancelEditingAction"), forControlEvents: .TouchUpInside)

        submitButton.setImage(ElloDrawable.imageOfSubmitIcon, forState: .Normal)
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
        for view in [backButton, avatarView, buttonContainer, textContainer, sayElloOverlay] as [UIView] {
            self.addSubview(view)
        }
        for view in [cameraButton, cancelButton, submitButton] as [UIView] {
            buttonContainer.addSubview(view)
        }
        sayElloOverlay.addSubview(sayElloLabel)
        textContainer.addSubview(textView)
    }

// MARK: Public interface

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

    func reportSuccess(title : String) {
        let alertController = UIAlertController(title: title, message: "", preferredStyle: .Alert)

        let cancelAction = UIAlertAction(title: "OK", style: .Cancel) { (action) in }
        alertController.addAction(cancelAction)

        delegate?.omnibarPresentController(alertController)
        self.resetAfterSuccessfulPost()
    }

    private func resetAfterSuccessfulPost() {
        resetUndoState()
        resetEditor()
    }

    func reportError(title : String, error : NSError) {
        let errorMessage = error.localizedDescription
        reportError(title, error: errorMessage)
    }

    func reportError(title : String, error message : String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)

        let cancelAction = UIAlertAction(title: "OK", style: .Cancel) { (action) in }
        alertController.addAction(cancelAction)

        delegate?.omnibarPresentController(alertController)
    }

// MARK: Keyboard events - animate layout update in conjunction with keyboard animation

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

// MARK: Layout and update views

    override func layoutSubviews() {
        super.layoutSubviews()

        var avatarViewLeft = Size.margins
        if hasParentPost {
            backButton.frame = CGRect(x: Size.margins, y: Size.margins, width: 29.0, height: Size.toolbarHeight)
            avatarViewLeft += backButton.frame.maxX
        }

        avatarView.frame = CGRect(x: avatarViewLeft, y: Size.margins, width: Size.toolbarHeight, height: Size.toolbarHeight)
        avatarView.layer.cornerRadius = Size.toolbarHeight / CGFloat(2)

        let buttonContainerWidth = Size.buttonWidth * CGFloat(buttonContainer.subviews.count)
        buttonContainer.frame = CGRect(x: self.bounds.width - Size.buttonRightMargin, y: Size.margins, width: 0, height: Size.toolbarHeight)
            .growLeft(buttonContainerWidth)

        // make sure the textContainer is above the keboard, with a 1pt line
        // margin at the bottom.
        // size the textContainer and sayElloOverlay to be identical.
        let kbdHeight = Keyboard.shared().height
        let window : UIView = self.window ?? self
        let bottom = self.convertPoint(CGPoint(x: 0, y: self.bounds.height), toView: window).y
        let bottomHeight = window.frame.height - bottom
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

        // size so that it is offset from the textContainer
        textView.frame = textContainer.bounds.inset(top: 0, left: Size.textMargins, bottom: 0, right: 0)
        textView.contentInset = UIEdgeInsets(top: Size.textMargins, left: 0, bottom: Size.textMargins, right: 0)
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
            cancelButton.setImage(ElloDrawable.imageOfUndoIcon, forState: .Normal)
            cancelButton.removeTarget(self, action: Selector("cancelEditingAction"), forControlEvents: .TouchUpInside)
            cancelButton.addTarget(self, action: Selector("undoCancelAction"), forControlEvents: .TouchUpInside)
        }
        else {
            cancelButton.setImage(ElloDrawable.imageOfCancelIcon, forState: .Normal)
            cancelButton.removeTarget(self, action: Selector("undoCancelAction"), forControlEvents: .TouchUpInside)
            cancelButton.addTarget(self, action: Selector("cancelEditingAction"), forControlEvents: .TouchUpInside)
        }
    }

// MARK: Button Actions

    func backAction() {
        self.delegate?.omnibarCancel()
    }

    func startEditingAction() {
        sayElloOverlay.hidden = true
        textView.becomeFirstResponder()
    }

    func cancelEditingAction() {
        takeUndoSnapshot()
        resetEditor()
    }

    func undoCancelAction() {
        currentText = undoText
        textView.attributedText = undoText
        setCurrentImage(undoImage)
        if currentTextIsPresent() {
            startEditingAction()
        }

        resetUndoState()
    }

    func submitAction() {
        if currentTextIsPresent() || currentImageIsPresent() {
            textView.resignFirstResponder()
            var submittedText : NSAttributedString?
            if currentTextIsPresent() {
                submittedText = currentText
            }
            delegate?.omnibarSubmitted(submittedText, image: currentImage)
        }
    }

    func removeButtonAction() {
        userSetCurrentImage(nil)
    }

// MARK: Undo logic

    private func currentTextIsPresent() -> Bool {
        return currentText != nil && countElements(currentText!.string) > 0
    }

    private func currentImageIsPresent() -> Bool {
        return currentImage != nil
    }

    private func undoTextIsPresent() -> Bool {
        return undoText != nil && countElements(undoText!.string) > 0
    }

    private func undoImageIsPresent() -> Bool {
        return undoImage != nil
    }

    private func resetUndoState() {
        undoText = nil
        undoImage = nil
        updateUndoState()
    }

    func canUndo() -> Bool {
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
                imageSelectedImageView.contentMode = .ScaleAspectFit
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
        Functional.later(0.3) {
            self.cancelButton.userInteractionEnabled = true
        }
    }

// MARK: Camera / Image Picker

    func addImageAction() {
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            let alertController = UIAlertController(title: "Choose a photo source", message: "", preferredStyle: .ActionSheet)

            let cameraAction = UIAlertAction(title: "📷 Camera", style: .Default) { (action) in self.openCamera() }
            alertController.addAction(cameraAction)

            let libraryAction = UIAlertAction(title: "📱 Library", style: .Default) { (action) in self.openLibrary() }
            alertController.addAction(libraryAction)

            let cancelAction = UIAlertAction(title: "🚫 Cancel", style: .Cancel) { (action) in }
            alertController.addAction(cancelAction)

            delegate?.omnibarPresentController(alertController)
        }
        else if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
            openLibrary()
        }
        else {
            let alertController = UIAlertController(title: "No photo library", message: "Sorry, but your device doesn’t have a photo library!", preferredStyle: .Alert)

            let cancelAction = UIAlertAction(title: "OK", style: .Cancel) { (action) in }
            alertController.addAction(cancelAction)

            delegate?.omnibarPresentController(alertController)
        }
    }

    func openLibrary() {
        let imageController = UIImagePickerController()
        imageController.sourceType = .PhotoLibrary
        openImagePicker(imageController)
    }

    func openCamera() {
        let imageController = UIImagePickerController()
        imageController.sourceType = .Camera
        openImagePicker(imageController)
    }

    private func openImagePicker(imageController : UIImagePickerController) {
        imageController.mediaTypes = [kUTTypeImage]
        imageController.allowsEditing = false
        imageController.delegate = self
        imageController.modalPresentationStyle = .FullScreen
        imageController.navigationBar.tintColor = UIColor.greyA()
        delegate?.omnibarPresentController(imageController)
    }

    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .None)
    }

    func imagePickerController(controller: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        let mediaType = info[UIImagePickerControllerMediaType] as String
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            userSetCurrentImage(image)
        }
        delegate?.omnibarDismissController(controller)
    }

    func imagePickerControllerDidCancel(controller: UIImagePickerController) {
        delegate?.omnibarDismissController(controller)
    }

    func showCamera() {
    }

    func showLibrary() {
    }

// MARK: Text View editing

    func textViewShouldBeginEditing(textView : UITextView) -> Bool {
        return true
    }

    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText: String) -> Bool {
        let newText = NSString(string: textView.text).stringByReplacingCharactersInRange(range, withString: replacementText)
        self.currentText = ElloAttributedString.style(newText)

        updateUndoState()

        return true
    }

}
