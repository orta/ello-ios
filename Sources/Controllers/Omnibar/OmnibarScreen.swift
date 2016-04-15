//
//  OmnibarScreen.swift
//  Ello
//
//  Created by Colin Gray on 2/26/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import MobileCoreServices
import FLAnimatedImage
import PINRemoteImage
import ImagePickerSheetController


public class OmnibarScreen: UIView, OmnibarScreenProtocol {
    struct Size {
        static let margins = UIEdgeInsets(top: 17, left: 15, bottom: 10, right: 21)
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

    public var interactionEnabled: Bool = true {
        didSet {
            userInteractionEnabled = interactionEnabled
            boldButton.userInteractionEnabled = interactionEnabled
            italicButton.userInteractionEnabled = interactionEnabled
            linkButton.userInteractionEnabled = interactionEnabled
            keyboardSubmitButton.userInteractionEnabled = interactionEnabled
        }
    }

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

    public var submitTitle: String = "" {
        didSet {
            for button in [tabbarSubmitButton, keyboardSubmitButton] {
                button.setTitle(submitTitle, forState: .Normal)
            }
        }
    }

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
    let cameraButton = UIButton()

// MARK: keyboard buttons
    var keyboardButtonViews: [UIView]!
    var keyboardButtonView = UIView()
    let boldButton = UIButton()
    let italicButton = UIButton()
    let linkButton = UIButton()
    let keyboardSubmitButton = UIButton()
    let tabbarSubmitButton = UIButton()

    let regionsTableView = UITableView()
    let textEditingControl = UIControl()
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

        regionsTableView.addObserver(self, forKeyPath: "contentSize", options: [.New], context: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        regionsTableView.removeObserver(self, forKeyPath: "contentSize", context: nil)
    }

    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        let sup = { super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context) }
        guard let keyPath = keyPath, change = change else {
            sup()
            return
        }

        switch keyPath {
        case "contentSize":
            if let contentSize = (change[NSKeyValueChangeNewKey] as? NSValue)?.CGSizeValue() {
                let contentHeight: CGFloat = ceil(contentSize.height) + regionsTableView.contentInset.bottom
                let height: CGFloat = max(0, regionsTableView.frame.height - contentHeight)
                let y = regionsTableView.frame.height - height - regionsTableView.contentInset.bottom
                textEditingControl.frame = CGRect(
                    x: 0,
                    y: y,
                    width: self.frame.width,
                    height: height
                    )
            }
        default:
            sup()
        }
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
        avatarButton.addTarget(self, action: #selector(OmnibarScreen.profileImageTapped), forControlEvents: .TouchUpInside)
    }

    private func setupNavigationBar() {
        let backItem = UIBarButtonItem.backChevronWithTarget(self, action: #selector(OmnibarScreen.backAction))
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
        cancelButton.contentEdgeInsets = UIEdgeInsets(top: 4, left: 9.5, bottom: 4, right: 9.5)
        cancelButton.setImages(.X)
        cancelButton.addTarget(self, action: #selector(OmnibarScreen.cancelEditingAction), forControlEvents: .TouchUpInside)

        reorderButton.contentEdgeInsets = UIEdgeInsets(top: 4, left: 9.5, bottom: 4, right: 9.5)
        reorderButton.setImages(.Reorder)
        reorderButton.addTarget(self, action: #selector(OmnibarScreen.toggleReorderingTable), forControlEvents: .TouchUpInside)

        cameraButton.contentEdgeInsets = UIEdgeInsets(top: 4, left: 9.5, bottom: 4, right: 9.5)
        cameraButton.setImages(.Camera)
        cameraButton.addTarget(self, action: #selector(OmnibarScreen.addImageAction), forControlEvents: .TouchUpInside)

        for button in [tabbarSubmitButton, keyboardSubmitButton] {
            button.backgroundColor = UIColor.blackColor()
            button.setImages(.Pencil, white: true)
            button.setTitle(InterfaceString.Omnibar.CreatePostButton, forState: .Normal)
            button.setTitleColor(.whiteColor(), forState: .Normal)
            button.setTitleColor(.grey6(), forState: .Disabled)
            button.titleLabel?.font = UIFont.defaultFont()
            button.contentEdgeInsets.left = -5
            button.imageEdgeInsets.right = 5
            button.addTarget(self, action: #selector(OmnibarScreen.submitAction), forControlEvents: .TouchUpInside)
            button.frame.size.height = Size.keyboardButtonSize.height
        }
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

        textEditingControl.addTarget(self, action: #selector(OmnibarScreen.startEditingLast), forControlEvents: .TouchUpInside)
        regionsTableView.addSubview(textEditingControl)

        textScrollView.delegate = self
        let stopEditingTapGesture = UITapGestureRecognizer(target: self, action: #selector(OmnibarScreen.stopEditing))
        textScrollView.addGestureRecognizer(stopEditingTapGesture)
        let stopEditingSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(OmnibarScreen.stopEditing))
        stopEditingSwipeGesture.direction = .Down
        textScrollView.addGestureRecognizer(stopEditingSwipeGesture)
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

        boldButton.addTarget(self, action: #selector(OmnibarScreen.boldButtonTapped), forControlEvents: .TouchUpInside)
        boldButton.setAttributedTitle(NSAttributedString(string: "B", attributes: [
            NSFontAttributeName: UIFont.defaultBoldFont(),
            NSForegroundColorAttributeName: UIColor.whiteColor()
        ]), forState: .Normal)
        boldButton.setAttributedTitle(NSAttributedString(string: "B", attributes: [
            NSFontAttributeName: UIFont.defaultBoldFont(),
            NSForegroundColorAttributeName: UIColor.grey6()
        ]), forState: .Highlighted)
        boldButton.setAttributedTitle(NSAttributedString(string: "B", attributes: [
            NSFontAttributeName: UIFont.defaultBoldFont(),
            NSForegroundColorAttributeName: UIColor.blackColor()
            ]), forState: .Selected)

        italicButton.addTarget(self, action: #selector(OmnibarScreen.italicButtonTapped), forControlEvents: .TouchUpInside)
        italicButton.setAttributedTitle(NSAttributedString(string: "I", attributes: [
            NSFontAttributeName: UIFont.defaultItalicFont(),
            NSForegroundColorAttributeName: UIColor.whiteColor()
        ]), forState: .Normal)
        italicButton.setAttributedTitle(NSAttributedString(string: "I", attributes: [
            NSFontAttributeName: UIFont.defaultItalicFont(),
            NSForegroundColorAttributeName: UIColor.grey6()
        ]), forState: .Highlighted)
        italicButton.setAttributedTitle(NSAttributedString(string: "I", attributes: [
            NSFontAttributeName: UIFont.defaultItalicFont(),
            NSForegroundColorAttributeName: UIColor.blackColor()
            ]), forState: .Selected)

        linkButton.addTarget(self, action: #selector(OmnibarScreen.linkButtonTapped), forControlEvents: .TouchUpInside)
        linkButton.enabled = false
        linkButton.setImage(.Link, imageStyle: .White, forState: .Normal)
        linkButton.setImage(.BreakLink, imageStyle: .White, forState: .Selected)
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
            cameraButton,
        ]
        for button in toolbarButtonViews as [UIView] {
            self.addSubview(button)
        }

        for button in keyboardButtonViews as [UIView] {
            keyboardButtonView.addSubview(button)
        }

        addSubview(tabbarSubmitButton)
        keyboardButtonView.addSubview(keyboardSubmitButton)

        textScrollView.addSubview(textContainer)
        textScrollView.addSubview(textView)
        textView.inputAccessoryView = keyboardButtonView
        textScrollView.hidden = true
    }

// MARK: Generate regions

    func generateEditableRegions(regions: [OmnibarRegion]) -> [IndexedRegion] {
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
    }

// MARK: Public interface

    public func resetAfterSuccessfulPost() {
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

    func updateText(text: NSAttributedString, atPath path: NSIndexPath) {
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

    func startEditingLast() {
        var lastTextRow: Int?
        for (row, indexedRegion) in editableRegions.enumerate() {
            let region = indexedRegion.1
            if region.isText {
                lastTextRow = row
            }
        }

        if let lastTextRow = lastTextRow {
            startEditingAtPath(NSIndexPath(forRow: lastTextRow, inSection: 0))
        }
    }

    public func startEditing() {
        var firstTextRow: Int?
        for (row, indexedRegion) in editableRegions.enumerate() {
            let region = indexedRegion.1
            if region.isText {
                firstTextRow = row
                break
            }
        }

        if let firstTextRow = firstTextRow {
            startEditingAtPath(NSIndexPath(forRow: firstTextRow, inSection: 0))
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

    private func convertReorderableRegions(reorderableRegions: [IndexedRegion]) -> [OmnibarRegion] {
        var regions = [OmnibarRegion]()
        var buffer = ElloAttributedString.style("")
        var lastRegionIsText = false
        for (_, region) in reorderableRegions {
            switch region {
            case let .AttributedText(text):
                buffer = buffer.joinWithNewlines(text)
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
            reorderButton.setImages(.Check)
            reorderButton.selected = true
        }
        else {
            submitableRegions = convertReorderableRegions(reorderableRegions)
            editableRegions = generateEditableRegions(submitableRegions)
            reorderButton.setImages(.Reorder)
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

        let cancelAction = AlertAction(title: InterfaceString.OK, style: .Light, handler: .None)
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

    func resignKeyboard() {
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
        for view in toolbarButtonViews.reverse() {
            view.frame.size = view.intrinsicContentSize()
            buttonX -= view.frame.size.width
            view.frame.origin = CGPoint(x: buttonX, y: toolbarTop)
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
        tabbarSubmitButton.frame.size = CGSize(width: frame.width, height: Size.keyboardButtonSize.height)

        if Keyboard.shared().active {
            tabbarSubmitButton.frame.origin.y = frame.height
        }
        else {
            tabbarSubmitButton.frame.origin.y = frame.height - ElloTabBar.Size.height - Size.keyboardButtonSize.height
        }

        var x = CGFloat(0)
        for view in keyboardButtonViews {
            view.frame.origin.x = x
            x += view.frame.size.width
            x += Size.keyboardButtonMargin
        }
        let remainingCameraWidth = frame.width - x
        keyboardSubmitButton.frame.origin.x = keyboardButtonView.frame.width - remainingCameraWidth
        keyboardSubmitButton.frame.size.width = remainingCameraWidth
    }

    func synchronizeScrollViews() {
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
        let canSubmit = !reordering && canPost()
        keyboardSubmitButton.enabled = canSubmit
        tabbarSubmitButton.enabled = canSubmit
    }

// MARK: Button Actions

    func backAction() {
        delegate?.omnibarCancel()
    }

    public func cancelEditingAction() {
        if reordering {
            reorderingTable(false)
        }
        else if canPost() && !isEditing {
            let alertController = AlertViewController()

            let deleteAction = AlertAction(title: InterfaceString.Delete, style: ActionStyle.Dark, handler: { _ in
                self.resetEditor()
            })
            alertController.addAction(deleteAction)

            let cancelAction = AlertAction(title: InterfaceString.Cancel, style: .Light, handler: .None)
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
        let fontName = (font ?? UIFont.editorFont()).fontName

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
        let fontName = (font ?? UIFont.editorFont()).fontName

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

        let urlAction = AlertAction(title: InterfaceString.Omnibar.EnterURL, style: .URLInput)
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
            reorderableRegions = generateReorderableRegions(submitableRegions)

            regionsTableView.reloadData()
            regionsTableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.tableViewRegions.count - 1, inSection: 0), atScrollPosition: .None, animated: true)
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
        let pickerSheet = UIImagePickerController.imagePickerSheetForImagePicker(openImageSheet)
        self.delegate?.omnibarPresentController(pickerSheet)
    }

}
