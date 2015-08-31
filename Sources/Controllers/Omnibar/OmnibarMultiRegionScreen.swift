//
//  OmnibarMultiRegionScreen.swift
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
    case Error

    public static func Text(str: String) -> OmnibarRegion {
        return AttributedText(ElloAttributedString.style(str))
    }
}


public class OmnibarMultiRegionScreen: UIView, OmnibarScreenProtocol {
    struct Size {
        static let margins = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
        static let textMargins = UIEdgeInsets(top: 22, left: 30, bottom: 9, right: 30)
        static let labelCorrection = CGFloat(8.5)
        static let innerTextMargin = CGFloat(11)
        static let bottomTextMargin = CGFloat(1)
        static let toolbarHeight = CGFloat(60)
        static let buttonHeight = CGFloat(45)
        static let buttonWidth = CGFloat(70)
    }

    class func canEditRegions(regions: [Regionable]?) -> Bool {
        if let regions = regions {
            return count(regions) > 0 && regions.all { region in
                return region is TextRegion || region is ImageRegion
            }
        }
        return false
    }

    var autoCompleteVC = AutoCompleteViewController()

    public var isEditing: Bool = false
    public var reordering = false

    public var regions: [OmnibarRegion] {
        set {
            var regions = newValue
            if let last = regions.last where !last.isText {
                regions.append(.Text(""))
            }
            else if count(regions) == 0 {
                regions.append(.Text(""))
            }
            _regions = regions
            generateTableRegions()
            regionsTableView.reloadData()
            updateButtons()
        }
        get { return _regions }
    }
    public var _regions: [OmnibarRegion]
    public var tableViewRegions: [(Int?, OmnibarRegion)] {
        if reordering {
            return reorderableRegions
        }
        else {
            return editableRegions
        }
    }
    public var reorderableRegions = [(Int?, OmnibarRegion)]()
    public var editableRegions = [(Int?, OmnibarRegion)]()

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
                    self.avatarButton.pin_setImageFromURL(avatarURL)                }
                else {
                    self.avatarButton.setImage(nil, forState: .Normal)
                }
            }
        }
    }

    public var avatarImage: UIImage? {
        willSet(newValue) {
            if avatarImage != newValue {
                if let avatarImage = newValue {
                    self.avatarButton.setImage(avatarImage, forState: .Normal)
                }
                else {
                    self.avatarButton.setImage(nil, forState: .Normal)
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

    public let avatarButton = UIButton()
    public let editButton = ElloEditButton()

    public let cancelButton = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
    public let cameraButton = UIButton(frame: CGRect(x: 44, y: 0, width: 44, height: 44))
    public let navigationBar = ElloNavigationBar(frame: CGRectZero)
    public let submitButton = ElloPostButton(frame: CGRect(x: 98, y: 0, width: 44, height: 44))
    public let buttonContainer = UIView(frame: CGRect(x: 0, y: 0, width: 142, height: 60))
    let statusBarUnderlay = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 20))

    let regionsTableView = UITableView()
    let textScrollView = UIScrollView()
    let textContainer = UIView()
    public let textView: UITextView
    var autoCompleteContainer = UIView()
    var autoCompleteThrottle = debounce(0.4)
    var autoCompleteShowing = false
    private var currentImage: UIImage?

// MARK: init

    override public init(frame: CGRect) {
        _regions = [.Text("")]
        textView = OmnibarTextCell.generateTextView()
        textView.backgroundColor = UIColor.clearColor()
        super.init(frame: frame)

        backgroundColor = UIColor.whiteColor()
        autoCompleteContainer.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: 0)

        generateTableRegions()
        setupAutoComplete()
        setupAvatarView()
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

        editButton.setTitle(NSLocalizedString("Edit", comment: "Edit button title"), forState: .Normal)
        editButton.addTarget(self, action: Selector("toggleReorderingTable"), forControlEvents: .TouchUpInside)
    }

    private func setupNavigationBar() {
        let backItem = UIBarButtonItem.backChevronWithTarget(self, action: Selector("backAction"))
        navigationItem.leftBarButtonItem = backItem
        navigationItem.fixNavBarItemPadding()
        navigationBar.items = [navigationItem]

        statusBarUnderlay.frame.size.width = frame.width
        statusBarUnderlay.backgroundColor = .blackColor()
        statusBarUnderlay.autoresizingMask = .FlexibleWidth | .FlexibleBottomMargin
        addSubview(statusBarUnderlay)
    }

    // buttons that make up the "toolbar"
    private func setupToolbarButtons() {
        cameraButton.setSVGImages("camera")
        cameraButton.addTarget(self, action: Selector("addImageAction"), forControlEvents: .TouchUpInside)

        cancelButton.setSVGImages("x")
        cancelButton.addTarget(self, action: Selector("cancelEditingAction"), forControlEvents: .TouchUpInside)

        submitButton.addTarget(self, action: Selector("submitAction"), forControlEvents: .TouchUpInside)
        submitButton.setTitleColor(UIColor.whiteColor(), forState: .Disabled)
        let image = SVGKImage(named: "arrow_white").UIImage!
        let imageView = UIImageView(image: image)
        imageView.center = CGPoint(x: submitButton.frame.width - image.size.width / 2 - 13, y: submitButton.frame.height / CGFloat(2))
        imageView.autoresizingMask = .FlexibleLeftMargin | .FlexibleTopMargin | .FlexibleBottomMargin
        submitButton.addSubview(imageView)
    }

    // The textContainer is the outer gray background.  The text view is
    // configured to fill that container (only the container and the text view
    // insets are modified in layoutSubviews)
    private func setupTextViews() {
        regionsTableView.dataSource = self
        regionsTableView.delegate = self
        regionsTableView.separatorStyle = .None
        regionsTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "OmnibarSpacerCell")
        regionsTableView.registerClass(OmnibarTextCell.self, forCellReuseIdentifier: OmnibarTextCell.reuseIdentifier())
        regionsTableView.registerClass(OmnibarImageCell.self, forCellReuseIdentifier: OmnibarImageCell.reuseIdentifier())
        regionsTableView.registerClass(OmnibarImageDownloadCell.self, forCellReuseIdentifier: OmnibarImageDownloadCell.reuseIdentifier())

        textScrollView.delegate = self
        let gesture = UITapGestureRecognizer(target: self, action: Selector("stopEditing"))
        textScrollView.addGestureRecognizer(gesture)
        textScrollView.clipsToBounds = true
        textContainer.backgroundColor = UIColor.greyE5()

        textView.clipsToBounds = false
        textView.editable = true
        textView.allowsEditingTextAttributes = true
        textView.selectable = true
        textView.delegate = self
        textView.autoresizingMask = .FlexibleHeight | .FlexibleWidth
        textView.autocorrectionType = .Yes
        textView.inputAccessoryView = autoCompleteContainer
    }

    private func setupViewHierarchy() {
        let views = [
            regionsTableView,
            textScrollView,
            navigationBar,
            avatarButton,
            editButton,
            buttonContainer,
        ]
        for view in views as [UIView] {
            self.addSubview(view)
        }
        for view in [cancelButton, cameraButton, submitButton] as [UIView] {
            buttonContainer.addSubview(view)
        }

        textScrollView.addSubview(textContainer)
        textScrollView.addSubview(textView)
        textScrollView.hidden = true
    }
    private func setupSwipeGesture() {
        let gesture = UISwipeGestureRecognizer()
        gesture.direction = .Down
        gesture.addTarget(self, action: Selector("swipedDown"))
        textScrollView.addGestureRecognizer(gesture)
    }

// MARK: Generate regions

    private func generateTableRegions() {
        var editableRegions = [(Int?, OmnibarRegion)]()
        var prevWasImage = false
        for (index, region) in enumerate(_regions) {
            if region.isImage && prevWasImage {
                editableRegions.append((nil, .Spacer))
                prevWasImage = true
            }
            editableRegions.append((index, region))
            prevWasImage = region.isImage
        }
        self.editableRegions = editableRegions
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

    public func startEditingAtPath(path: NSIndexPath) {
        currentTextPath = path
        textScrollView.hidden = false
        textScrollView.contentOffset = regionsTableView.contentOffset
        textScrollView.contentInset = regionsTableView.contentInset
        textScrollView.scrollIndicatorInsets = regionsTableView.scrollIndicatorInsets
        textScrollView.scrollsToTop = true
        regionsTableView.scrollsToTop = false
        updateEditingAtPath(path)
    }

    public func updateEditingAtPath(path: NSIndexPath, scrollPosition: UITableViewScrollPosition = .Middle) {
        var rect = regionsTableView.rectForRowAtIndexPath(path)
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

    private func generateReorderableRegions() {
        reorderableRegions = [(Int?, OmnibarRegion)]()
        for region in _regions {
            if region.editable && !region.empty {
                switch region {
                case .Image, .ImageURL:
                    reorderableRegions.append((nil, region))
                case let .AttributedText(text):
                    if count(text.string) > 0 {
                        reorderableRegions.append((nil, .AttributedText(text)))
                    }
                default: break
                }
            }
        }
        editableRegions.filter { (_, region) in return region.editable && !region.empty }
    }

    private func generateEditableRegions() {
        _regions = [OmnibarRegion]()
        var buffer = NSMutableAttributedString(attributedString: ElloAttributedString.style(""))
        var lastRegionIsText = false
        for (_, region) in reorderableRegions {
            switch region {
            case let .AttributedText(text):
                if count(buffer.string) > 0 {
                    if !buffer.string.endsWith("\n") {
                        buffer.appendAttributedString(ElloAttributedString.style("\n\n"))
                    }
                    else if !buffer.string.endsWith("\n\n") {
                        buffer.appendAttributedString(ElloAttributedString.style("\n"))
                    }
                }
                buffer.appendAttributedString(text)
                lastRegionIsText = true
            case .Image:
                if count(buffer.string) > 0 {
                    _regions.append(.AttributedText(buffer))
                }
                _regions.append(region)
                buffer = NSMutableAttributedString(attributedString: ElloAttributedString.style(""))
                lastRegionIsText = false
            default: break
            }
        }
        if count(buffer.string) > 0 {
            _regions.append(.AttributedText(buffer))
        }
        else if !lastRegionIsText {
            _regions.append(.Text(""))
        }
        generateTableRegions()
    }

    public func reorderingTable(reordering: Bool) {
        if reordering {
            generateReorderableRegions()
            if count(reorderableRegions) == 0 { return }

            stopEditing()
            editButton.setTitle(NSLocalizedString("Done", comment: "Done button title"), forState: .Normal)
        }
        else {
            generateEditableRegions()
            editButton.setTitle(NSLocalizedString("Edit", comment: "Edit button title"), forState: .Normal)
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
        editingCanceled()
        UIView.animateWithDuration(Keyboard.shared().duration,
            delay: 0.0,
            options: Keyboard.shared().options,
            animations: {
                self.layoutIfNeeded()
            },
            completion: nil)
    }

    private func resignKeyboard() {
        textView.resignFirstResponder()
        regions = regions.filter { !$0.empty }
    }

// MARK: Layout and update views

    override public func layoutSubviews() {
        super.layoutSubviews()

        var screenTop = CGFloat(20)
        if canGoBack {
            UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Slide)
            navigationBar.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: ElloNavigationBar.Size.height)
            screenTop += navigationBar.frame.height
            statusBarUnderlay.hidden = true
        }
        else {
            navigationBar.frame = CGRectZero
            statusBarUnderlay.hidden = false
        }

        var avatarViewLeft = Size.margins.left
        avatarButton.frame = CGRect(x: avatarViewLeft, y: screenTop + Size.margins.top, width: Size.toolbarHeight, height: Size.toolbarHeight)
        avatarButton.layer.cornerRadius = avatarButton.frame.size.height / CGFloat(2)

        editButton.frame = CGRect(x: avatarButton.frame.maxX + 2, y: avatarButton.frame.minY, width: 55, height: avatarButton.frame.height)

        buttonContainer.frame = CGRect(x: frame.width - Size.margins.right, y: screenTop + Size.margins.top, width: 0, height: Size.toolbarHeight)
            .growLeft(buttonContainer.frame.width)
        for view in buttonContainer.subviews as! [UIView] {
            view.center.y = buttonContainer.frame.height / 2
        }

        regionsTableView.frame = CGRect(x: 0, y: buttonContainer.frame.maxY + Size.innerTextMargin, right: bounds.size.width, bottom: bounds.size.height)
        textScrollView.frame = regionsTableView.frame

        var bottomInset = Keyboard.shared().keyboardBottomInset(inView: self)
        if bottomInset == 0 {
            bottomInset = ElloTabBar.Size.height + Size.margins.bottom
        }
        else {
            bottomInset += Size.bottomTextMargin
        }

        regionsTableView.contentInset.bottom = bottomInset
        regionsTableView.scrollIndicatorInsets.bottom = bottomInset
        synchronizeScrollViews()
    }

    private func synchronizeScrollViews() {
        textScrollView.contentSize = regionsTableView.contentSize
        textScrollView.contentInset = regionsTableView.contentInset
        textScrollView.scrollIndicatorInsets = regionsTableView.scrollIndicatorInsets
    }

    private func resetEditor() {
        hideAutoComplete(textView)
        resignKeyboard()
        textView.text = ""
        updateButtons()
        _regions = [.Text("")]
        generateTableRegions()
        regionsTableView.reloadData()
    }

    public func updateButtons() {
        cameraButton.enabled = !reordering
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
            delegate?.omnibarSubmitted(_regions)
        }
    }

    public func swipedDown() {
        resignKeyboard()
    }

// MARK: Post logic

    public func canPost() -> Bool {
        for region in _regions {
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
            var prevCount = count(editableRegions)

            if let region = _regions.last where region.empty {
                let lastIndex = count(_regions) - 1
                _regions.removeAtIndex(lastIndex)
                let lastIndexPath = NSIndexPath(forItem: count(editableRegions) - 1, inSection: 0)
                prevCount -= 1
            }

            _regions.append(.Image(image, data, type))
            _regions.append(.Text(""))
            generateTableRegions()
            let diffCount = count(editableRegions) - prevCount
            let paths = (1...diffCount).map { NSIndexPath(forItem: count(self.editableRegions) - $0, inSection: 0) }.reverse()
            regionsTableView.reloadData()
            regionsTableView.scrollToRowAtIndexPath(paths.last!, atScrollPosition: .None, animated: true)
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
        let alert = UIImagePickerController.alertControllerForImagePicker(openImagePicker)
        alert.map { self.delegate?.omnibarPresentController($0) }
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

extension OmnibarMultiRegionScreen: UITableViewDelegate, UITableViewDataSource {
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewRegions.count
    }

    public func tableView(tableView: UITableView, heightForRowAtIndexPath path: NSIndexPath) -> CGFloat {
        if let (_, region) = tableViewRegions.safeValue(path.row) {
            switch region {
            case let .AttributedText(attrdString):
                return OmnibarTextCell.heightForText(attrdString, tableWidth: regionsTableView.frame.width)
            case let .Image(image, _, _):
                return OmnibarImageCell.heightForImage(image, tableWidth: regionsTableView.frame.width, editing: reordering)
            case let .ImageURL(url):
                return OmnibarImageDownloadCell.Size.height
            case let .Spacer:
                return OmnibarImageCell.Size.bottomMargin
            default:
                break
            }
        }
        return 0
    }

    public func tableView(tableView: UITableView, cellForRowAtIndexPath path: NSIndexPath) -> UITableViewCell {
        if let (_, region) = tableViewRegions.safeValue(path.row) {
            let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(region.reuseIdentifier, forIndexPath: path) as! UITableViewCell
            cell.selectionStyle = .None
            cell.showsReorderControl = true

            switch region {
            case let .AttributedText(attributedText):
                let textCell = cell as! OmnibarTextCell
                textCell.attributedText = attributedText
            case let .Image(image, _, _):
                let imageCell = cell as! OmnibarImageCell
                imageCell.omnibarImage = image
                imageCell.reordering = reordering
            default: break
            }
            return cell
        }
        return UITableViewCell()
    }

    public func tableView(tableView: UITableView, didSelectRowAtIndexPath path: NSIndexPath) {
        if let (_, region) = tableViewRegions.safeValue(path.row) {
            switch region {
            case let .AttributedText(attributedText):
                startEditingAtPath(path)
                textView.attributedText = attributedText
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
        if let source = reorderableRegions.safeValue(sourcePath.row), dest = reorderableRegions.safeValue(destPath.row) {
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
        if let (index_, region) = reorderableRegions.safeValue(path.row)
            where region.editable
        {
            reorderableRegions.removeAtIndex(path.row)
            regionsTableView.deleteRowsAtIndexPaths([path], withRowAnimation: .Automatic)
            if count(reorderableRegions) == 0 {
                reorderingTable(false)
            }
        }
    }

    public func deleteEditableAtIndexPath(path: NSIndexPath) {
        if let (index_, region) = editableRegions.safeValue(path.row),
            index = index_ where region.editable
        {
            if count(editableRegions) == 1 {
                _regions = [.Text("")]
                generateTableRegions()
                regionsTableView.reloadRowsAtIndexPaths([path], withRowAnimation: .Automatic)
            }
            else if let regionAbove = _regions.safeValue(index - 1),
                regionAboveText = regionAbove.text,
                regionBelow = _regions.safeValue(index + 1),
                regionBelowText = regionBelow.text
            where regionAbove.isText && regionBelow.isText
            {
                let newText = NSMutableAttributedString()
                newText.appendAttributedString(regionAboveText)

                if count(regionBelowText.string.trim()) > 0 {
                    if count(regionAboveText.string.trim()) > 0 && !regionAboveText.string.endsWith("\n\n") {
                        if regionAboveText.string.endsWith("\n") {
                            newText.appendAttributedString(ElloAttributedString.style("\n"))
                        }
                        else {
                            newText.appendAttributedString(ElloAttributedString.style("\n\n"))
                        }
                    }
                    newText.appendAttributedString(regionBelowText)
                }

                _regions.removeAtIndex(index + 1)
                _regions.removeAtIndex(index)
                _regions[index - 1] = .AttributedText(newText)

                regionsTableView.beginUpdates()
                generateTableRegions()
                regionsTableView.reloadRowsAtIndexPaths([NSIndexPath(forItem: path.row - 1, inSection: 0)], withRowAnimation: .None)
                regionsTableView.deleteRowsAtIndexPaths([
                    path,
                    NSIndexPath(forItem: path.row + 1, inSection: 0),
                ], withRowAnimation: .Automatic)
                regionsTableView.endUpdates()
            }
            else if let regionAbove = _regions.safeValue(index - 1),
                regionBelow = _regions.safeValue(index + 1)
            where regionAbove.isImage && regionBelow.isImage
            {
                _regions.removeAtIndex(index)
                generateTableRegions()
                regionsTableView.reloadData()
            }
            else {
                _regions.removeAtIndex(index)
                var paths = [path]

                // remove the spacer *after* the deleted row (if it's the first
                // or N-1th row in series of image rows), and *before* the last
                // row (if it's the last row in a series of image rows)
                if let (_, region) = editableRegions.safeValue(path.row + 1) where region.isSpacer {
                    paths.append(NSIndexPath(forItem: path.row + 1, inSection: 0))
                }
                else if let (_, region) = editableRegions.safeValue(path.row - 1) where region.isSpacer {
                    paths.append(NSIndexPath(forItem: path.row - 1, inSection: 0))
                }

                regionsTableView.beginUpdates()
                if let last = _regions.last where !last.isText {
                    let insertPath = NSIndexPath(forItem: count(_regions), inSection: 0)
                    _regions.append(.Text(""))
                    regionsTableView.insertRowsAtIndexPaths([insertPath], withRowAnimation: .Automatic)
                }
                generateTableRegions()
                regionsTableView.deleteRowsAtIndexPaths(paths, withRowAnimation: .Automatic)
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
        if scrollView == regionsTableView {
        }
        else {
            regionsTableView.contentOffset = scrollView.contentOffset
        }
    }

}


// MARK: UITextViewDelegate
extension OmnibarMultiRegionScreen: UITextViewDelegate {
    public func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        return true
    }

    private func throttleAutoComplete(textView: UITextView, range: NSRange) {
        self.autoCompleteThrottle { [unowned self] in
            let autoComplete = AutoComplete()
            // deleting characters yields a range.length > 0, go back 1 character for deletes
            let location = range.length > 0 && range.location > 0 ? range.location - 1 : range.location
            if let match = autoComplete.check(textView.text, location: location) {
                self.autoCompleteVC.load(match) { count in
                    if count > 0 {
                        self.showAutoComplete(textView, count: count)
                    }
                    else if count == 0 {
                        self.hideAutoComplete(textView)
                    }
                }
            } else {
                self.hideAutoComplete(textView)
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
        if let path = currentTextPath, cell = regionsTableView.cellForRowAtIndexPath(path) {
            let currentText = textView.attributedText
            let newRegion: OmnibarRegion = .AttributedText(currentText)
            let (index, _) = editableRegions[path.row]
            if let index = index {
                _regions[index] = newRegion
                editableRegions[path.row] = (index, newRegion)

                regionsTableView.reloadData()
                updateEditingAtPath(path, scrollPosition: .Bottom)
            }
        }
        updateButtons()
    }

    private func emojiKeyboardShowing() -> Bool {
        return textView.textInputMode?.primaryLanguage == nil || textView.textInputMode?.primaryLanguage == "emoji"
    }

    private func hideAutoComplete(textView: UITextView) {
        if autoCompleteShowing {
            autoCompleteShowing = false
            textView.autocorrectionType = .Yes
            textView.inputAccessoryView = nil
            textView.resignFirstResponder()
            textView.becomeFirstResponder()
        }
    }

    private func showAutoComplete(textView: UITextView, count: Int) {
        if !autoCompleteShowing {
            autoCompleteShowing = true
            textView.inputAccessoryView = autoCompleteContainer
            textView.autocorrectionType = .No
            textView.resignFirstResponder()
            textView.becomeFirstResponder()
        }

        let height: CGFloat = count > 3 ? AutoCompleteCell.cellHeight() * 3 : AutoCompleteCell.cellHeight() * CGFloat(count)
        if let constraint = textView.inputAccessoryView?.constraints().first as? NSLayoutConstraint {
            constraint.constant = height
        }
        autoCompleteContainer.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: height)
        autoCompleteVC.view.frame = autoCompleteContainer.frame
    }
}


extension OmnibarMultiRegionScreen: AutoCompleteDelegate {
    public func itemSelected(item: AutoCompleteItem) {
        if let name = item.result.name {
            let prefix = item.type == .Username ? "@" : ":"
            let newText = textView.text.stringByReplacingCharactersInRange(item.match.range, withString: prefix + name + " ")
            let currentText = ElloAttributedString.style(newText)
            textView.attributedText = currentText
            updateButtons()
            hideAutoComplete(textView)
        }
    }
}


// MARK: UIImagePickerControllerDelegate
extension OmnibarMultiRegionScreen: UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    private func openImagePicker(imageController: UIImagePickerController) {
        resignKeyboard()
        imageController.delegate = self
        delegate?.omnibarPresentController(imageController)
    }

    public func imagePickerController(controller: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject: AnyObject]) {
        let library = PHPhotoLibrary.sharedPhotoLibrary()
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            if let url = info[UIImagePickerControllerReferenceURL] as? NSURL,
               let asset = PHAsset.fetchAssetsWithALAssetURLs([url], options: nil).firstObject as? PHAsset
            {
                    PHImageManager.defaultManager().requestImageDataForAsset(asset, options: nil) { imageData, dataUTI, orientation, info in
                        var buffer = UnsafeMutablePointer<UInt8>.alloc(imageData.length)
                        imageData.getBytes(buffer, length: imageData.length)
                        if self.isGif(buffer, length: imageData.length) {
                            self.addImage(image, data: imageData, type: "image/gif")
                        }
                        else {
                            self.addImage(image)
                        }
                        buffer.dealloc(imageData.length)
                        self.delegate?.omnibarDismissController(controller)
                    }
            }
            else {
                image.copyWithCorrectOrientationAndSize() { image in
                    self.addImage(image)
                    self.delegate?.omnibarDismissController(controller)
                }
            }
        }
        else {
            delegate?.omnibarDismissController(controller)
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
        case let .AttributedText(text): return count(text.string) > 0
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
        case let .AttributedText(text): return count(text.string) == 0
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
        case .Spacer: return "OmnibarSpacerCell"
        case .Error: return ""
        }
    }
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

extension OmnibarRegion: Printable, DebugPrintable {
    public var description: String {
        switch self {
        case let .Image(image, _, _): return "Image(size: \(image.size))"
        case let .ImageURL(url): return "ImageURL(url: \(url))"
        case let .AttributedText(text): return "AttributedText(text: \(text.string))"
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
