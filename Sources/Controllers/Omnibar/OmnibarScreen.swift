//
//  OmnibarScreen.swift
//  Ello
//
//  Created by Colin Gray on 2/26/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices
import FLAnimatedImage
import SVGKit
import PINRemoteImage


public protocol OmnibarScreenDelegate: class {
    func omnibarCancel()
    func omnibarPushController(controller: UIViewController)
    func omnibarPresentController(controller: UIViewController)
    func omnibarDismissController(controller: UIViewController)
    func omnibarSubmitted(regions: [OmnibarRegion])
}


public protocol OmnibarScreenProtocol: class {
    var delegate: OmnibarScreenDelegate? { get set }
    var title: String { get set }
    var regions: [OmnibarRegion] { get set }
    var avatarURL: NSURL? { get set }
    var avatarImage: UIImage? { get set }
    var currentUser: User? { get set }
    var canGoBack: Bool { get set }
    var isEditing: Bool { get set }
    func reportSuccess(title: String)
    func reportError(title: String, error: NSError)
    func reportError(title: String, errorMessage: String)
    func keyboardWillShow()
    func keyboardWillHide()
    func startEditing()
    func stopEditing()
    func updateButtons()
}


public enum OmnibarRegion {
    case Image(UIImage, NSData?, String?)
    case ImageURL(NSURL)
    case AttributedText(NSAttributedString)
    case Spacer
    case Error(NSURL)

    public static func Text(str: String) -> OmnibarRegion {
        return AttributedText(ElloAttributedString.style(str))
    }
}


public class OmnibarScreen: UIView, OmnibarScreenProtocol {
    struct Size {
        static let margins = UIEdgeInsets(top: 17, left: 15, bottom: 10, right: 15)
        static let toolbarMargin = CGFloat(10)
        static let tableTopInset = CGFloat(22.5)
        static let bottomTextMargin = CGFloat(1)
        static let avatarSize = CGFloat(30)
        static let keyboardButtonSize = CGSize(width: 54, height: 44)
        static let keyboardButtonMargin = CGFloat(1)
    }

    class func canEditRegions(regions: [Regionable]?) -> Bool {
        if let regions = regions {
            return regions.count > 0 && regions.all { region in
                return region is TextRegion || region is ImageRegion
            }
        }
        return false
    }

    var autoCompleteVC = AutoCompleteViewController()

    public var isEditing = false
    public var reordering = false

    public typealias IndexedRegion = (Int?, OmnibarRegion)
    public var regions: [OmnibarRegion] {
        set {
            var regions = newValue
            if let last = regions.last where !last.isText {
                regions.append(.Text(""))
            }
            else if regions.count == 0 {
                regions.append(.Text(""))
            }
            submitableRegions = regions
            editableRegions = generateEditableRegions(submitableRegions)
            regionsTableView.reloadData()
            updateButtons()
        }
        get { return submitableRegions }
    }
    public var submitableRegions: [OmnibarRegion]
    public var tableViewRegions: [IndexedRegion] {
        if reordering {
            return reorderableRegions
        }
        else {
            return editableRegions
        }
    }
    public var reorderableRegions = [IndexedRegion]()
    public var editableRegions = [IndexedRegion]()

    public var currentTextPath: NSIndexPath?

    public var title: String = "" {
        didSet {
            navigationItem.title = title
        }
    }
    public let navigationItem = UINavigationItem()

    public var avatarURL: NSURL? {
        willSet(newValue) {
            if avatarURL != newValue {
                if let avatarURL = newValue {
                    avatarButton.pin_setImageFromURL(avatarURL)
                }
                else {
                    avatarButton.pin_cancelImageDownload()
                    avatarButton.setImage(nil, forState: .Normal)
                }
            }
        }
    }

    public var avatarImage: UIImage? {
        willSet(newValue) {
            if avatarImage != newValue {
                avatarButton.pin_cancelImageDownload()
                if let avatarImage = newValue {
                    avatarButton.setImage(avatarImage, forState: .Normal)
                }
                else {
                    avatarButton.setImage(nil, forState: .Normal)
                }
            }
        }
    }

    public var canGoBack: Bool = false {
        didSet { setNeedsLayout() }
    }

    public var currentUser: User?

// MARK: internal and/or private vars

    weak public var delegate: OmnibarScreenDelegate?

    let statusBarUnderlay = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 20))
    let navigationBar = ElloNavigationBar(frame: CGRectZero)

// MARK: toolbar buttons
    var toolbarButtonViews: [UIView]!
    let avatarButton = UIButton()
    let cancelButton = UIButton()
    let reorderButton = UIButton()
    let submitButton = ElloPostButton()

// MARK: keyboard buttons
    var keyboardButtonViews: [UIView]!
    var keyboardButtonView = UIView()
    let boldButton = UIButton()
    let italicButton = UIButton()
    let linkButton = UIButton()
    let keyboardCameraButton = UIButton()
    let tabbarCameraButton = UIButton()

    let regionsTableView = UITableView()
    let textScrollView = UIScrollView()
    let textContainer = UIView()
    let textView: UITextView
    var autoCompleteContainer = UIView()
    var autoCompleteThrottle = debounce(0.4)
    var autoCompleteShowing = false

// MARK: init

    override public init(frame: CGRect) {
        submitableRegions = [.Text("")]
        textView = OmnibarTextCell.generateTextView()
        textView.backgroundColor = UIColor.clearColor()
        textView.tintColor = UIColor.blackColor()
        textView.keyboardAppearance = .Dark

        super.init(frame: frame)

        backgroundColor = UIColor.whiteColor()
        autoCompleteContainer.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: 0)

        editableRegions = generateEditableRegions(submitableRegions)
        setupAutoComplete()
        setupAvatarView()
        setupNavigationBar()
        setupToolbarButtons()
        setupTableViews()
        setupKeyboardViews()
        setupViewHierarchy()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

// MARK: View setup code

    private func setupAutoComplete() {
        autoCompleteVC.view.frame = autoCompleteContainer.frame
        autoCompleteVC.delegate = self
        autoCompleteContainer.addSubview(autoCompleteVC.view)
    }

    // Avatar view (in the upper right corner) just needs to round its corners,
    // which is done in layoutSubviews.
    private func setupAvatarView() {
        avatarButton.backgroundColor = UIColor.blackColor()
        avatarButton.clipsToBounds = true
        avatarButton.addTarget(self, action: Selector("profileImageTapped"), forControlEvents: .TouchUpInside)
    }

    private func setupNavigationBar() {
        let backItem = UIBarButtonItem.backChevronWithTarget(self, action: Selector("backAction"))
        navigationItem.leftBarButtonItem = backItem
        navigationItem.fixNavBarItemPadding()
        navigationBar.items = [navigationItem]

        statusBarUnderlay.frame.size.width = frame.width
        statusBarUnderlay.backgroundColor = .blackColor()
        statusBarUnderlay.autoresizingMask = [.FlexibleWidth, .FlexibleBottomMargin]
        addSubview(statusBarUnderlay)
    }

    // buttons that make up the "toolbar"
    private func setupToolbarButtons() {
        cancelButton.contentEdgeInsets = UIEdgeInsets(top: 4, left: 7.5, bottom: 4, right: 7.5)
        cancelButton.setSVGImages("x")
        cancelButton.addTarget(self, action: Selector("cancelEditingAction"), forControlEvents: .TouchUpInside)

        reorderButton.contentEdgeInsets = UIEdgeInsets(top: 4, left: 12.5, bottom: 4, right: 12.5)
        reorderButton.setSVGImages("reorder")
        reorderButton.addTarget(self, action: Selector("toggleReorderingTable"), forControlEvents: .TouchUpInside)

        submitButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 35, bottom: 8, right: 15)
        submitButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        submitButton.addTarget(self, action: Selector("submitAction"), forControlEvents: .TouchUpInside)
    }

    // The textContainer is the outer gray background.  The text view is
    // configured to fill that container (only the container and the text view
    // insets are modified in layoutSubviews)
    private func setupTableViews() {
        regionsTableView.dataSource = self
        regionsTableView.delegate = self
        regionsTableView.separatorStyle = .None
        regionsTableView.registerClass(OmnibarTextCell.self, forCellReuseIdentifier: OmnibarTextCell.reuseIdentifier())
        regionsTableView.registerClass(OmnibarImageCell.self, forCellReuseIdentifier: OmnibarImageCell.reuseIdentifier())
        regionsTableView.registerClass(OmnibarImageDownloadCell.self, forCellReuseIdentifier: OmnibarImageDownloadCell.reuseIdentifier())
        regionsTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: OmnibarRegion.OmnibarSpacerCell)
        regionsTableView.registerClass(OmnibarErrorCell.self, forCellReuseIdentifier: OmnibarErrorCell.reuseIdentifier())

        textScrollView.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("stopEditing"))
        textScrollView.addGestureRecognizer(tapGesture)
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: Selector("stopEditing"))
        swipeGesture.direction = .Down
        textScrollView.addGestureRecognizer(swipeGesture)
        textScrollView.clipsToBounds = true
        textContainer.backgroundColor = UIColor.whiteColor()

        textView.clipsToBounds = false
        textView.editable = true
        textView.allowsEditingTextAttributes = false
        textView.selectable = true
        textView.delegate = self
        textView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        textView.autocorrectionType = .Yes
    }

    private func setupKeyboardViews() {
        keyboardButtonViews = [
            boldButton,
            italicButton,
            linkButton,
        ]

        keyboardButtonView.backgroundColor = UIColor.greyC()
        for button in keyboardButtonViews as [UIView] {
            button.backgroundColor = UIColor.greyA()
            button.frame.size = Size.keyboardButtonSize
        }

        boldButton.addTarget(self, action: Selector("boldButtonTapped"), forControlEvents: .TouchUpInside)
        boldButton.setAttributedTitle(NSAttributedString(string: "B", attributes: [
            NSFontAttributeName: UIFont.typewriterBoldFont(12),
            NSForegroundColorAttributeName: UIColor.whiteColor()
        ]), forState: .Normal)
        boldButton.setAttributedTitle(NSAttributedString(string: "B", attributes: [
            NSFontAttributeName: UIFont.typewriterBoldFont(12),
            NSForegroundColorAttributeName: UIColor.grey6()
        ]), forState: .Highlighted)
        boldButton.setAttributedTitle(NSAttributedString(string: "B", attributes: [
            NSFontAttributeName: UIFont.typewriterBoldFont(12),
            NSForegroundColorAttributeName: UIColor.blackColor()
            ]), forState: .Selected)

        italicButton.addTarget(self, action: Selector("italicButtonTapped"), forControlEvents: .TouchUpInside)
        italicButton.setAttributedTitle(NSAttributedString(string: "I", attributes: [
            NSFontAttributeName: UIFont.typewriterItalicFont(12),
            NSForegroundColorAttributeName: UIColor.whiteColor()
        ]), forState: .Normal)
        italicButton.setAttributedTitle(NSAttributedString(string: "I", attributes: [
            NSFontAttributeName: UIFont.typewriterItalicFont(12),
            NSForegroundColorAttributeName: UIColor.grey6()
        ]), forState: .Highlighted)
        italicButton.setAttributedTitle(NSAttributedString(string: "I", attributes: [
            NSFontAttributeName: UIFont.typewriterItalicFont(12),
            NSForegroundColorAttributeName: UIColor.blackColor()
            ]), forState: .Selected)

        linkButton.addTarget(self, action: Selector("linkButtonTapped"), forControlEvents: .TouchUpInside)
        linkButton.enabled = false
        linkButton.setImage(SVGKImage(named: "link_white.svg").UIImage!, forState: .Normal)
        linkButton.setImage(SVGKImage(named: "breaklink_white.svg").UIImage!, forState: .Selected)

        for button in [tabbarCameraButton, keyboardCameraButton] {
            button.backgroundColor = UIColor.blackColor()
            button.setSVGImages("camera", white: true)
            button.addTarget(self, action: Selector("addImageAction"), forControlEvents: .TouchUpInside)
            button.frame.size.height = Size.keyboardButtonSize.height
        }
    }

    private func setupViewHierarchy() {
        let views = [
            regionsTableView,
            textScrollView,
            navigationBar,
            avatarButton,
        ]
        for view in views as [UIView] {
            self.addSubview(view)
        }

        toolbarButtonViews = [
            cancelButton,
            reorderButton,
            submitButton,
        ]
        for button in toolbarButtonViews as [UIView] {
            self.addSubview(button)
        }

        for button in keyboardButtonViews as [UIView] {
            keyboardButtonView.addSubview(button)
        }

        addSubview(tabbarCameraButton)
        keyboardButtonView.addSubview(keyboardCameraButton)

        textScrollView.addSubview(textContainer)
        textScrollView.addSubview(textView)
        textView.inputAccessoryView = keyboardButtonView
        textScrollView.hidden = true
    }

// MARK: Generate regions

    private func generateEditableRegions(regions: [OmnibarRegion]) -> [IndexedRegion] {
        var editableRegions = [IndexedRegion]()
        for (index, region) in regions.enumerate() {
            if index > 0 {
                editableRegions.append((nil, .Spacer))
            }
            editableRegions.append((index, region))
            if let path = currentTextPath where path.row == editableRegions.count - 1 {
                textView.attributedText = region.text
            }
        }
        return editableRegions
        // NB: don't call `reloadData` here, because this method is called as part of
        // lots of table view updates
    }

// MARK: Public interface

    public func reportSuccess(title: String) {
        let alertController = AlertViewController(message: title)

        let cancelAction = AlertAction(title: NSLocalizedString("OK", comment: "ok button"), style: .Light, handler: .None)
        alertController.addAction(cancelAction)

        delegate?.omnibarPresentController(alertController)
        self.resetAfterSuccessfulPost()
    }

    private func resetAfterSuccessfulPost() {
        resetEditor()
    }

    public func profileImageTapped() {
        if let userParam = currentUser?.id {
            let profileVC = ProfileViewController(userParam: userParam)
            profileVC.currentUser = self.currentUser
            self.delegate?.omnibarPushController(profileVC)
        }
    }

    // called on a user action that should resign the keyboard
    public func stopEditing() {
        resignKeyboard()
        editingCanceled()
    }

// MARK: Internal, but might need to be testable

    // called whenever the keyboard is dismissed, by user or system
    private func editingCanceled() {
        textScrollView.hidden = true
        textScrollView.scrollsToTop = false
        regionsTableView.scrollsToTop = true
        currentTextPath = nil
    }

    private func updateCurrentText(text: NSAttributedString) {
        if let path = currentTextPath {
            updateText(text, atPath: path)
        }
    }

    private func updateText(text: NSAttributedString, atPath path: NSIndexPath) {
        let newRegion: OmnibarRegion = .AttributedText(text)
        let (index, _) = editableRegions[path.row]
        if let index = index {
            submitableRegions[index] = newRegion
            editableRegions[path.row] = (index, newRegion)

            regionsTableView.reloadData()
            updateEditingAtPath(path, scrollPosition: .Bottom)
        }
    }

    public func startEditingAtPath(path: NSIndexPath) {
        if let (_, region) = tableViewRegions.safeValue(path.row) where region.isText {
            currentTextPath = path
            textScrollView.hidden = false
            textScrollView.contentOffset = regionsTableView.contentOffset
            textScrollView.contentInset = regionsTableView.contentInset
            textScrollView.scrollIndicatorInsets = regionsTableView.scrollIndicatorInsets
            textScrollView.scrollsToTop = true
            regionsTableView.scrollsToTop = false
            textView.attributedText = region.text
            updateEditingAtPath(path)
        }
    }

    public func updateEditingAtPath(path: NSIndexPath, scrollPosition: UITableViewScrollPosition = .Middle) {
        let rect = regionsTableView.rectForRowAtIndexPath(path)
        textScrollView.contentSize = regionsTableView.contentSize
        textView.frame = OmnibarTextCell.boundsForTextView(rect)
        textContainer.frame = textView.frame.grow(all: 10)
        textView.becomeFirstResponder()
    }

    public func startEditing() {
        if let (_, region) = editableRegions.first where region.isText {
            startEditingAtPath(NSIndexPath(forItem: 0, inSection: 0))
        }
    }

    public func toggleReorderingTable() {
        reorderingTable(!reordering)
    }

    private func generateReorderableRegions(regions: [OmnibarRegion]) -> [IndexedRegion] {
        let nonEmptyRegions = regions.filter { region in
            return region.editable && !region.empty
        }
        return nonEmptyRegions.map { (region: OmnibarRegion) -> IndexedRegion in
            return (nil, region)
        }
    }

    private func joinTwoAttributedStrings(t1: NSAttributedString, _ t2: NSAttributedString) -> NSAttributedString {
        let str = NSMutableAttributedString(attributedString: t1)
        if t2.string.characters.count > 0 {
            if t1.string.characters.count > 0 {
                if !t1.string.endsWith("\n") {
                    str.appendAttributedString(ElloAttributedString.style("\n\n"))
                }
                else if !t1.string.endsWith("\n\n") {
                    str.appendAttributedString(ElloAttributedString.style("\n"))
                }
            }
            str.appendAttributedString(t2)
        }
        return str
    }

    private func convertReorderableRegions(reorderableRegions: [IndexedRegion]) -> [OmnibarRegion] {
        var regions = [OmnibarRegion]()
        var buffer = ElloAttributedString.style("")
        var lastRegionIsText = false
        for (_, region) in reorderableRegions {
            switch region {
            case let .AttributedText(text):
                buffer = joinTwoAttributedStrings(buffer, text)
                lastRegionIsText = true
            case .Image:
                if buffer.string.characters.count > 0 {
                    regions.append(.AttributedText(buffer))
                }
                regions.append(region)
                buffer = ElloAttributedString.style("")
                lastRegionIsText = false
            default: break
            }
        }
        if buffer.string.characters.count > 0 {
            regions.append(.AttributedText(buffer))
        }
        else if !lastRegionIsText {
            regions.append(.Text(""))
        }
        return regions
    }

    public func reorderingTable(reordering: Bool) {
        if reordering {
            reorderableRegions = generateReorderableRegions(submitableRegions)
            if reorderableRegions.count == 0 { return }

            stopEditing()
            reorderButton.setSVGImages("check")
            reorderButton.selected = true
        }
        else {
            submitableRegions = convertReorderableRegions(reorderableRegions)
            editableRegions = generateEditableRegions(submitableRegions)
            reorderButton.setSVGImages("reorder")
            reorderButton.selected = false
        }

        self.reordering = reordering
        regionsTableView.setEditing(reordering, animated: true)
        updateButtons()
        regionsTableView.reloadData()
    }

    public func reportError(title: String, error: NSError) {
        let errorMessage = error.elloErrorMessage ?? error.localizedDescription
        reportError(title, errorMessage: errorMessage)
    }

    public func reportError(title: String, errorMessage: String) {
        let alertController = AlertViewController(message: "\(title)\n\n\(errorMessage)\n\nIf you are uploading multiple images, this error could be due to slow internet and/or too many images.")

        let cancelAction = AlertAction(title: NSLocalizedString("OK", comment: "ok button"), style: .Light, handler: .None)
        alertController.addAction(cancelAction)

        delegate?.omnibarPresentController(alertController)
    }

// MARK: Keyboard events - animate layout update in conjunction with keyboard animation

    public func keyboardWillShow() {
        self.setNeedsLayout()
        animate(duration: Keyboard.shared().duration, options: Keyboard.shared().options) {
            self.layoutIfNeeded()
        }
    }

    public func keyboardWillHide() {
        self.setNeedsLayout()
        animate(duration: Keyboard.shared().duration, options: Keyboard.shared().options) {
            self.layoutIfNeeded()
        }
    }

    private func resignKeyboard() {
        textView.resignFirstResponder()
        regions = regions.filter { !$0.empty }
    }

// MARK: Layout and update views

    override public func layoutSubviews() {
        super.layoutSubviews()

        let screenTop: CGFloat
        if canGoBack {
            UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Slide)
            navigationBar.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: ElloNavigationBar.Size.height)
            screenTop = navigationBar.frame.height
            statusBarUnderlay.hidden = true
        }
        else {
            screenTop = CGFloat(20)
            navigationBar.frame = CGRectZero
            statusBarUnderlay.hidden = false
        }

        let toolbarTop = screenTop + Size.margins.top
        var buttonX = frame.width - Size.margins.right
        var firstMargin = CGFloat(10)
        for view in toolbarButtonViews.reverse() {
            view.frame.size = view.intrinsicContentSize()
            buttonX -= view.frame.size.width
            view.frame.origin = CGPoint(x: buttonX, y: toolbarTop)

            buttonX -= firstMargin
            firstMargin = 0
        }

        let avatarViewLeft = Size.margins.left
        let avatarViewTop = toolbarTop
        avatarButton.frame = CGRect(x: avatarViewLeft, y: avatarViewTop, width: Size.avatarSize, height: Size.avatarSize)
        avatarButton.layer.cornerRadius = avatarButton.frame.size.height / CGFloat(2)

        regionsTableView.frame = CGRect(x: 0, y: avatarButton.frame.maxY + Size.toolbarMargin, right: bounds.size.width, bottom: bounds.size.height)
        textScrollView.frame = regionsTableView.frame

        var bottomInset = Keyboard.shared().keyboardBottomInset(inView: self)

        if bottomInset == 0 {
            bottomInset = ElloTabBar.Size.height + Size.keyboardButtonSize.height
        }
        else {
            bottomInset += Size.keyboardButtonSize.height
        }

        regionsTableView.contentInset.top = Size.tableTopInset
        regionsTableView.contentInset.bottom = bottomInset
        regionsTableView.scrollIndicatorInsets.bottom = bottomInset
        synchronizeScrollViews()

        keyboardButtonView.frame.size = CGSize(width: frame.width, height: Size.keyboardButtonSize.height)
        tabbarCameraButton.frame.size = CGSize(width: frame.width, height: Size.keyboardButtonSize.height)

        if Keyboard.shared().active {
            tabbarCameraButton.frame.origin.y = frame.height
        }
        else {
            tabbarCameraButton.frame.origin.y = frame.height - ElloTabBar.Size.height - Size.keyboardButtonSize.height
        }

        var x = CGFloat(0)
        for view in keyboardButtonViews {
            view.frame.origin.x = x
            x += view.frame.size.width
            x += Size.keyboardButtonMargin
        }
        let remainingCameraWidth = frame.width - x
        keyboardCameraButton.frame.origin.x = keyboardButtonView.frame.width - remainingCameraWidth
        keyboardCameraButton.frame.size.width = remainingCameraWidth
    }

    private func synchronizeScrollViews() {
        textScrollView.contentSize = regionsTableView.contentSize
        textScrollView.contentInset = regionsTableView.contentInset
        textScrollView.scrollIndicatorInsets = regionsTableView.scrollIndicatorInsets
    }

    private func resetEditor() {
        hideAutoComplete(textView)
        stopEditing()
        textView.text = ""
        updateButtons()
        submitableRegions = [.Text("")]
        editableRegions = generateEditableRegions(submitableRegions)
        regionsTableView.reloadData()
    }

    public func updateButtons() {
        submitButton.enabled = !reordering && canPost()
    }

// MARK: Button Actions

    func backAction() {
        delegate?.omnibarCancel()
    }

    public func startEditingAction() {
        startEditing()
    }

    public func cancelEditingAction() {
        if reordering {
            reorderingTable(false)
        }
        else if canPost() && !isEditing {
            let alertController = AlertViewController()

            let deleteAction = AlertAction(title: NSLocalizedString("Delete", comment: "Delete button"), style: ActionStyle.Dark, handler: { _ in
                self.resetEditor()
            })
            alertController.addAction(deleteAction)

            let cancelAction = AlertAction(title: NSLocalizedString("Cancel", comment: "Cancel button"), style: .Light, handler: .None)
            alertController.addAction(cancelAction)

            delegate?.omnibarPresentController(alertController)
        }
        else {
            delegate?.omnibarCancel()
        }
    }

    public func submitAction() {
        if canPost() {
            stopEditing()
            delegate?.omnibarSubmitted(submitableRegions)
        }
    }

    func boldButtonTapped() {
        let font = textView.typingAttributes[NSFontAttributeName] as? UIFont
        let fontName = font?.fontName ?? "AtlasTypewriter-Regular"

        let newFont: UIFont
        switch fontName {
        case UIFont.editorFont().fontName:
            newFont = UIFont.editorBoldFont()
            boldButton.selected = true
        case UIFont.editorItalicFont().fontName:
            newFont = UIFont.editorBoldItalicFont()
            boldButton.selected = true
        case UIFont.editorBoldFont().fontName:
            newFont = UIFont.editorFont()
            boldButton.selected = false
        case UIFont.editorBoldItalicFont().fontName:
            newFont = UIFont.editorItalicFont()
            boldButton.selected = false
        default:
            newFont = UIFont.editorBoldFont()
            boldButton.selected = true
        }

        if let selection = textView.selectedTextRange
            where !selection.empty
        {
            let range = textView.selectedRange
            let currentText = NSMutableAttributedString(attributedString: textView.attributedText)
            let attributes = [NSFontAttributeName: newFont]
            currentText.addAttributes(attributes, range: textView.selectedRange)
            textView.attributedText = currentText
            textView.selectedRange = range

            updateCurrentText(currentText)
        }
        else {
            textView.typingAttributes = ElloAttributedString.attrs([
                NSFontAttributeName: newFont,
            ])
        }
    }

    func italicButtonTapped() {
        let font = textView.typingAttributes[NSFontAttributeName] as? UIFont
        let fontName = font?.fontName ?? "AtlasTypewriter-Regular"

        let newFont: UIFont
        switch fontName {
        case UIFont.editorFont().fontName:
            newFont = UIFont.editorItalicFont()
            italicButton.selected = true
        case UIFont.editorItalicFont().fontName:
            newFont = UIFont.editorFont()
            italicButton.selected = false
        case UIFont.editorBoldFont().fontName:
            newFont = UIFont.editorBoldItalicFont()
            italicButton.selected = true
        case UIFont.editorBoldItalicFont().fontName:
            newFont = UIFont.editorBoldFont()
            italicButton.selected = false
        default:
            newFont = UIFont.editorItalicFont()
            italicButton.selected = true
        }

        if let selection = textView.selectedTextRange
            where !selection.empty
        {
            let range = textView.selectedRange
            let currentText = NSMutableAttributedString(attributedString: textView.attributedText)
            let attributes = [NSFontAttributeName: newFont]
            currentText.addAttributes(attributes, range: textView.selectedRange)
            textView.attributedText = currentText
            textView.selectedRange = range

            updateCurrentText(currentText)
        }
        else {
            textView.typingAttributes = ElloAttributedString.attrs([
                NSFontAttributeName: newFont,
            ])
        }
    }

    func linkButtonTapped() {
        var range = textView.selectedRange
        guard range.location != NSNotFound else { return }

        if range.length == 0 {
            range.location -= 1

            var effectiveRange: NSRange? = NSRange(location: 0, length: 0)
            if let _ = textView.textStorage.attribute(NSLinkAttributeName, atIndex: range.location, effectiveRange: &effectiveRange!),
                effectiveRange = effectiveRange
            {
                range = effectiveRange
            }
        }
        guard range.length > 0 else { return }

        let currentAttrs = textView.textStorage.attributesAtIndex(range.location, effectiveRange: nil)
        if currentAttrs[NSLinkAttributeName] != nil {
            textView.textStorage.removeAttribute(NSLinkAttributeName, range: range)
            textView.textStorage.removeAttribute(NSUnderlineStyleAttributeName, range: range)
            linkButton.selected = false
        }
        else {
            requestLinkURL() { url in
                if let url = url {
                    self.textView.textStorage.addAttributes([
                        NSLinkAttributeName: url,
                        NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue,
                        ], range: range)
                    self.linkButton.selected = true
                    self.linkButton.enabled = true
                    self.updateCurrentText(self.textView.textStorage)
                }
            }
        }

        linkButton.enabled = textView.selectedRange.length > 0
    }

    func requestLinkURL(handler: (NSURL?) -> Void) {
        let alertController = AlertViewController()

        let urlAction = AlertAction(title: NSLocalizedString("Enter the URL", comment: "Enter the URL"), style: .URLInput)
        alertController.addAction(urlAction)

        let okCancelAction = AlertAction(title: "", style: .OKCancel) { _ in
            if let urlString = alertController.actionInputs.safeValue(0) {
                let url: NSURL?
                if let urlTest = NSURL(string: urlString) where urlTest.scheme != "" {
                    url = urlTest
                }
                else if let urlTest = NSURL(string: "http://\(urlString)") {
                    url = urlTest
                }
                else {
                    url = nil
                }

                handler(url)
            }
        }
        alertController.addAction(okCancelAction)

        logPresentingAlert("OmnibarViewController")
        delegate?.omnibarPresentController(alertController)
    }

// MARK: Post logic

    public func canPost() -> Bool {
        for region in submitableRegions {
            if !region.empty {
                return true
            }
        }
        return false
    }

// MARK: Images

    // Notes on UITableView animations: since the modal is used here, the
    // animations only added complicated logic, no visual "bonus".  `reloadData`
    // is the way to go on this one.
    public func addImage(image: UIImage?, data: NSData? = nil, type: String? = nil) {
        if let image = image {
            if let region = submitableRegions.last where region.empty {
                let lastIndex = submitableRegions.count - 1
                submitableRegions.removeAtIndex(lastIndex)
            }

            submitableRegions.append(.Image(image, data, type))
            submitableRegions.append(.Text(""))
            editableRegions = generateEditableRegions(submitableRegions)

            regionsTableView.reloadData()
            regionsTableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.editableRegions.count - 1, inSection: 0), atScrollPosition: .None, animated: true)
        }

        updateButtons()
    }

    func userSetCurrentImageURL(imageURL: NSURL) {
        PINRemoteImageManager.sharedImageManager().downloadImageWithURL(imageURL) { result in
            if let image = result.image {
                self.addImage(image)
            }
        }
    }

// MARK: Camera / Image Picker

    public func addImageAction() {
		stopEditing()
        if let alert = UIImagePickerController.alertControllerForImagePicker(openImagePicker) {
            self.delegate?.omnibarPresentController(alert)
        }
    }

    private func isGif(buffer: UnsafeMutablePointer<UInt8>, length: Int) -> Bool {
        if length >= 4 {
            let isG = Int(buffer[0]) == 71
            let isI = Int(buffer[1]) == 73
            let isF = Int(buffer[2]) == 70
            let is8 = Int(buffer[3]) == 56

            return isG && isI && isF && is8
        }
        else {
            return false
        }
    }

}

extension OmnibarScreen: UITableViewDelegate, UITableViewDataSource {
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewRegions.count
    }

    public func tableView(tableView: UITableView, heightForRowAtIndexPath path: NSIndexPath) -> CGFloat {
        if let (_, region) = tableViewRegions.safeValue(path.row) {
            switch region {
            case let .AttributedText(attrdString):
                return OmnibarTextCell.heightForText(attrdString, tableWidth: regionsTableView.frame.width, editing: reordering)
            case let .Image(image, _, _):
                return OmnibarImageCell.heightForImage(image, tableWidth: regionsTableView.frame.width, editing: reordering)
            case .ImageURL:
                return OmnibarImageDownloadCell.Size.height
            case .Spacer:
                return OmnibarImageCell.Size.bottomMargin
            case .Error:
                return OmnibarErrorCell.Size.height
            }
        }
        return 0
    }

    public func tableView(tableView: UITableView, cellForRowAtIndexPath path: NSIndexPath) -> UITableViewCell {
        if let (_, region) = tableViewRegions.safeValue(path.row) {
            let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(region.reuseIdentifier, forIndexPath: path)
            cell.selectionStyle = .None
            cell.showsReorderControl = true

            switch region {
            case let .AttributedText(attributedText):
                let textCell = cell as! OmnibarTextCell
                textCell.isFirst = path.row == 0
                textCell.attributedText = attributedText
            case let .Image(image, data, _):
                let imageCell = cell as! OmnibarImageCell
                if let data = data {
                    imageCell.omnibarAnimagedImage = FLAnimatedImage(animatedGIFData: data)
                }
                else {
                    imageCell.omnibarImage = image
                }
                imageCell.reordering = reordering
            case let .Error(url):
                let textCell = cell as! OmnibarErrorCell
                textCell.url = url
            default: break
            }
            return cell
        }
        return UITableViewCell()
    }

    public func tableView(tableView: UITableView, didSelectRowAtIndexPath path: NSIndexPath) {
        if let (_, region) = tableViewRegions.safeValue(path.row) {
            switch region {
            case .AttributedText(_):
                startEditingAtPath(path)
            default:
                stopEditing()
            }
        }
    }

    public func tableView(tableView: UITableView, canMoveRowAtIndexPath path: NSIndexPath) -> Bool {
        if let (_, region) = tableViewRegions.safeValue(path.row) {
            switch region {
            case .Error, .Spacer: return false
            default: return true
            }
        }
        return false
    }

    public func tableView(tableView: UITableView, moveRowAtIndexPath sourcePath: NSIndexPath, toIndexPath destPath: NSIndexPath) {
        if let source = reorderableRegions.safeValue(sourcePath.row) {
            reorderableRegions.removeAtIndex(sourcePath.row)
            reorderableRegions.insert(source, atIndex: destPath.row)
        }
    }

    public func tableView(tableView: UITableView, canEditRowAtIndexPath path: NSIndexPath) -> Bool {
        if let (_, region) = tableViewRegions.safeValue(path.row) {
            return region.editable
        }
        return false
    }

    public func tableView(tableView: UITableView, commitEditingStyle style: UITableViewCellEditingStyle, forRowAtIndexPath path: NSIndexPath) {
        if style == .Delete {
            if reordering {
                deleteReorderableAtIndexPath(path)
            }
            else {
                deleteEditableAtIndexPath(path)
            }
        }
    }

    public func deleteReorderableAtIndexPath(path: NSIndexPath) {
        if let (_, region) = reorderableRegions.safeValue(path.row)
            where region.editable
        {
            reorderableRegions.removeAtIndex(path.row)
            regionsTableView.deleteRowsAtIndexPaths([path], withRowAnimation: .Automatic)
            if reorderableRegions.count == 0 {
                reorderingTable(false)
            }
        }
    }

    public func deleteEditableAtIndexPath(path: NSIndexPath) {
        if let (index_, region) = editableRegions.safeValue(path.row),
            index = index_ where region.editable
        {
            if editableRegions.count == 1 {
                submitableRegions = [.Text("")]
                editableRegions = generateEditableRegions(submitableRegions)
                regionsTableView.reloadRowsAtIndexPaths([path], withRowAnimation: .Top)
            }
            else {
                submitableRegions.removeAtIndex(index)
                var deletePaths = [path]
                var reloadPaths = [NSIndexPath]()
                var insertPaths = [NSIndexPath]()
                regionsTableView.beginUpdates()

                // remove the spacer *after* the deleted row (if it's the first
                // or N-1th row in series of image rows), and *before* the last
                // row (if it's the last row in a series of image rows)
                if let (_, belowTextRegion) = editableRegions.safeValue(path.row + 2),
                    (_, aboveTextRegion) = editableRegions.safeValue(path.row - 2),
                    belowText = belowTextRegion.text, aboveText = aboveTextRegion.text
                {
                    // merge text in submitableRegions
                    let newText = joinTwoAttributedStrings(aboveText, belowText)
                    submitableRegions[index - 1] = .AttributedText(newText)
                    submitableRegions.removeAtIndex(index)
                    reloadPaths.append(NSIndexPath(forItem: path.row - 2, inSection: 0))
                    deletePaths.append(NSIndexPath(forItem: path.row - 1, inSection: 0))
                    deletePaths.append(NSIndexPath(forItem: path.row + 1, inSection: 0))
                    deletePaths.append(NSIndexPath(forItem: path.row + 2, inSection: 0))
                }
                else if let last = submitableRegions.last where !last.isText {
                    insertPaths.append(path)
                    submitableRegions.append(.Text(""))
                }
                else if let (_, region) = editableRegions.safeValue(path.row + 1) where region.isSpacer {
                    deletePaths.append(NSIndexPath(forItem: path.row + 1, inSection: 0))
                }
                else if let (_, region) = editableRegions.safeValue(path.row - 1) where region.isSpacer {
                    deletePaths.append(NSIndexPath(forItem: path.row - 1, inSection: 0))
                }

                editableRegions = generateEditableRegions(submitableRegions)
                regionsTableView.deleteRowsAtIndexPaths(deletePaths, withRowAnimation: .Automatic)
                regionsTableView.reloadRowsAtIndexPaths(reloadPaths, withRowAnimation: .None)
                regionsTableView.insertRowsAtIndexPaths(insertPaths, withRowAnimation: .Automatic)
                regionsTableView.endUpdates()
            }
        }
        updateButtons()
    }

    public func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        if scrollView == textScrollView {
            synchronizeScrollViews()
        }
    }

    public func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView != regionsTableView {
            regionsTableView.contentOffset = scrollView.contentOffset
        }
    }

}


// MARK: UITextViewDelegate
extension OmnibarScreen: UITextViewDelegate {
    private func throttleAutoComplete(textView: UITextView, range: NSRange) {
        self.autoCompleteThrottle { [weak self] in
            let autoComplete = AutoComplete()
            // deleting characters yields a range.length > 0, go back 1 character for deletes
            let location = range.length > 0 && range.location > 0 ? range.location - 1 : range.location
            let text = textView.text
            if let match = autoComplete.check(text, location: location) {
                self?.autoCompleteVC.load(match) { count in
                    if text != textView.text { return }

                    if count > 0 {
                        self?.showAutoComplete(textView, count: count)
                    }
                    else if count == 0 {
                        self?.hideAutoComplete(textView)
                    }
                }
            } else {
                self?.hideAutoComplete(textView)
            }
        }
    }

    public func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText: String) -> Bool {
        if autoCompleteShowing && emojiKeyboardShowing() {
            return false
        }

        throttleAutoComplete(textView, range: range)
        nextTick { self.textViewDidChange(textView) }
        return true
    }

    public func textViewDidChange(textView: UITextView) {
        if let path = currentTextPath
            where regionsTableView.cellForRowAtIndexPath(path) != nil
        {
            var currentText = textView.attributedText
            if currentText.string.characters.count == 0 {
                currentText = ElloAttributedString.style("")
                textView.typingAttributes = ElloAttributedString.attrs()
                boldButton.selected = false
                italicButton.selected = false
            }

            updateText(currentText, atPath: path)
        }
        updateButtons()
    }

    public func textViewDidChangeSelection(textView: UITextView) {
        let font = textView.typingAttributes[NSFontAttributeName] as? UIFont
        let fontName = font?.fontName ?? "AtlasGrotesk-Regular"

        switch fontName {
        case UIFont.editorItalicFont().fontName:
            boldButton.selected = false
            italicButton.selected = true
        case UIFont.editorBoldFont().fontName:
            boldButton.selected = true
            italicButton.selected = false
        case UIFont.editorBoldItalicFont().fontName:
            boldButton.selected = true
            italicButton.selected = true
        default:
            boldButton.selected = false
            italicButton.selected = false
        }

        if let _ = textView.typingAttributes[NSLinkAttributeName] as? NSURL {
            linkButton.selected = true
            linkButton.enabled = true
        }
        else if let selection = textView.selectedTextRange
        where selection.empty {
            linkButton.selected = false
            linkButton.enabled = false
        }
        else {
            linkButton.selected = false
            linkButton.enabled = true
        }
    }

    private func emojiKeyboardShowing() -> Bool {
        return textView.textInputMode?.primaryLanguage == nil || textView.textInputMode?.primaryLanguage == "emoji"
    }

    private func hideAutoComplete(textView: UITextView) {
        if autoCompleteShowing {
            autoCompleteShowing = false
            textView.autocorrectionType = .Yes
            textView.inputAccessoryView = keyboardButtonView
            textView.resignFirstResponder()
            textView.becomeFirstResponder()
        }
    }

    private func showAutoComplete(textView: UITextView, count: Int) {
        if !autoCompleteShowing {
            autoCompleteShowing = true
            textView.autocorrectionType = .No
            let container = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 1))
            container.addSubview(autoCompleteContainer)
            textView.inputAccessoryView = container
            textView.resignFirstResponder()
            textView.becomeFirstResponder()
        }

        let height = AutoCompleteCell.cellHeight() * CGFloat(min(3, count))
        let constraintIndex = textView.inputAccessoryView?.constraints.indexOf { $0.firstAttribute == .Height }
        if let index = constraintIndex,
            inputAccessoryView = textView.inputAccessoryView,
            constraint = inputAccessoryView.constraints.safeValue(index)
        {
            constraint.constant = height
            inputAccessoryView.setNeedsUpdateConstraints()
            inputAccessoryView.frame.size.height = height
            inputAccessoryView.setNeedsLayout()
        }
        autoCompleteContainer.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: height)
        autoCompleteVC.view.frame = autoCompleteContainer.bounds
    }
}


extension OmnibarScreen: AutoCompleteDelegate {
    public func itemSelected(item: AutoCompleteItem) {
        if let name = item.result.name {
            let prefix = item.type == .Username ? "@" : ":"
            let newText = textView.text.stringByReplacingCharactersInRange(item.match.range, withString: prefix + name + " ")
            let currentText = ElloAttributedString.style(newText)
            textView.attributedText = currentText
            textViewDidChange(textView)
            updateButtons()
            hideAutoComplete(textView)
        }
    }
}


// MARK: UIImagePickerControllerDelegate
extension OmnibarScreen: UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    private func openImagePicker(imageController: UIImagePickerController) {
        resignKeyboard()
        imageController.delegate = self
        delegate?.omnibarPresentController(imageController)
    }

    public func imagePickerController(controller: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: AnyObject]) {
        func done() {
            self.delegate?.omnibarDismissController(controller)
        }

        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            if let url = info[UIImagePickerControllerReferenceURL] as? NSURL,
               asset = PHAsset.fetchAssetsWithALAssetURLs([url], options: nil).firstObject as? PHAsset
            {
                    PHImageManager.defaultManager().requestImageDataForAsset(asset, options: nil) { imageData, dataUTI, orientation, info in
                        if let imageData = imageData {
                            let buffer = UnsafeMutablePointer<UInt8>.alloc(imageData.length)
                            imageData.getBytes(buffer, length: imageData.length)
                            if self.isGif(buffer, length: imageData.length) {
                                self.addImage(image, data: imageData, type: "image/gif")
                                done()
                            }
                            else {
                                image.copyWithCorrectOrientationAndSize() { image in
                                    self.addImage(image)
                                    done()
                                }
                            }
                            buffer.dealloc(imageData.length)
                        }
                        else {
                            done()
                        }
                    }
            }
            else {
                image.copyWithCorrectOrientationAndSize() { image in
                    self.addImage(image)
                    done()
                }
            }
        }
        else {
            done()
        }
    }

    public func imagePickerControllerDidCancel(controller: UIImagePickerController) {
        delegate?.omnibarDismissController(controller)
    }
}


public extension OmnibarRegion {
    var editable: Bool {
        switch self {
        case .Image: return true
        case let .AttributedText(text): return text.string.characters.count > 0
        default: return false
        }
    }

    var text: NSAttributedString? {
        switch self {
        case let .AttributedText(text): return text
        default: return nil
        }
    }

    var image: UIImage? {
        switch self {
        case let .Image(image, _, _): return image
        default: return nil
        }
    }

    var isText: Bool {
        switch self {
        case .AttributedText: return true
        default: return false
        }
    }

    var isImage: Bool {
        switch self {
        case .Image: return true
        default: return false
        }
    }

    var empty: Bool {
        switch self {
        case let .AttributedText(text): return text.string.characters.count == 0
        case .Spacer: return true
        default: return false
        }
    }

    var isSpacer: Bool {
        switch self {
        case .Spacer: return true
        default: return false
        }
    }

    var reuseIdentifier: String {
        switch self {
        case .Image: return OmnibarImageCell.reuseIdentifier()
        case .ImageURL: return OmnibarImageDownloadCell.reuseIdentifier()
        case .AttributedText: return OmnibarTextCell.reuseIdentifier()
        case .Spacer: return OmnibarRegion.OmnibarSpacerCell
        case .Error: return OmnibarErrorCell.reuseIdentifier()
        }
    }

    static let OmnibarSpacerCell = "OmnibarSpacerCell"
}

public extension OmnibarRegion {
    var rawRegion: NSObject? {
        switch self {
        case let .Image(image, _, _): return image
        case let .AttributedText(text): return text
        default: return nil
        }
    }
    static func fromRaw(obj: NSObject) -> OmnibarRegion? {
        if let text = obj as? NSAttributedString {
            return .AttributedText(text)
        }
        else if let image = obj as? UIImage {
            return .Image(image, nil, nil)
        }
        return nil
    }
}

extension OmnibarRegion: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        switch self {
        case let .Image(image, _, _): return "Image(size: \(image.size))"
        case let .ImageURL(url): return "ImageURL(url: \(url))"
        case let .AttributedText(text): return "AttributedText(text: \(text.string))"
        case .Spacer: return "Spacer()"
        case .Error: return "Error()"
        }
    }
    public var debugDescription: String {
        switch self {
        case let .Image(image, _, _): return "Image(size: \(image.size))"
        case let .ImageURL(url): return "ImageURL(url: \(url))"
        case let .AttributedText(text): return "AttributedText(text: \(text.string))"
        case .Spacer: return "Spacer()"
        case .Error: return "Error()"
        }
    }

}
