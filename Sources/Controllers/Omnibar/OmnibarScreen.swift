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
        static let margins = UIEdgeInsets(top: 0, left: 15, bottom: 10, right: 15)
        static let textMargins = UIEdgeInsets(top: 22, left: 30, bottom: 9, right: 30)
        static let labelCorrection = CGFloat(8.5)
        static let tableTopInset = CGFloat(22.5)
        static let bottomTextMargin = CGFloat(1)
        static let toolbarMargins = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        static let toolbarHeight = CGFloat(45)
        static let avatarHeight = CGFloat(40)
        static let buttonMargin = CGFloat(10)
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
                    avatarButton.pin_setImageFromURL(avatarURL)                }
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

    public let navigationBar = ElloNavigationBar(frame: CGRectZero)

    public let avatarButton = UIButton()
    public let cancelButton = UIButton()
    public let editButton = UIButton()
    public let cameraButton = UIButton()
    public let submitButton = ElloPostButton()
    public let buttonContainer = UIView(frame: CGRect(x: 0, y: 0, width: 3 * Size.buttonMargin + 4 * Size.toolbarHeight, height: Size.toolbarHeight))
    let statusBarUnderlay = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 20))

    let regionsTableView = UITableView()
    let textScrollView = UIScrollView()
    let textContainer = UIView()
    public let textView: UITextView
    var autoCompleteContainer = UIView()
    var autoCompleteThrottle = debounce(0.4)
    var autoCompleteShowing = false

// MARK: init

    override public init(frame: CGRect) {
        submitableRegions = [.Text("")]
        textView = OmnibarTextCell.generateTextView()
        textView.backgroundColor = UIColor.clearColor()
        super.init(frame: frame)

        backgroundColor = UIColor.whiteColor()
        autoCompleteContainer.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: 0)

        editableRegions = generateEditableRegions(submitableRegions)
        setupAutoComplete()
        setupAvatarView()
        setupNavigationBar()
        setupToolbarButtons()
        setupTableViews()
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
        editButton.setSVGImages("reorder")
        editButton.addTarget(self, action: Selector("toggleReorderingTable"), forControlEvents: .TouchUpInside)

        cameraButton.setSVGImages("camera")
        cameraButton.addTarget(self, action: Selector("addImageAction"), forControlEvents: .TouchUpInside)

        cancelButton.setSVGImages("x")
        cancelButton.addTarget(self, action: Selector("cancelEditingAction"), forControlEvents: .TouchUpInside)

        submitButton.addTarget(self, action: Selector("submitAction"), forControlEvents: .TouchUpInside)
        submitButton.setTitleColor(UIColor.whiteColor(), forState: .Disabled)
        let image = SVGKImage(named: "arrow_white").UIImage!
        let imageView = UIImageView(image: image)
        imageView.center = CGPoint(x: submitButton.frame.width - image.size.width / 2 - 13, y: submitButton.frame.height / CGFloat(2))
        imageView.autoresizingMask = [.FlexibleLeftMargin, .FlexibleTopMargin, .FlexibleBottomMargin]
        submitButton.addSubview(imageView)
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

    private func setupViewHierarchy() {
        let views = [
            regionsTableView,
            textScrollView,
            navigationBar,
            avatarButton,
            buttonContainer,
        ]
        for view in views as [UIView] {
            self.addSubview(view)
        }

        for view in [cancelButton, editButton, cameraButton, submitButton] as [UIView] {
            buttonContainer.addSubview(view)
        }

        textScrollView.addSubview(textContainer)
        textScrollView.addSubview(textView)
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
            editButton.setSVGImages("check")
            editButton.selected = true
        }
        else {
            submitableRegions = convertReorderableRegions(reorderableRegions)
            editableRegions = generateEditableRegions(submitableRegions)
            editButton.setSVGImages("reorder")
            editButton.selected = false
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
        textView.resignFirstResponder()
        regions = regions.filter { !$0.empty }
    }

// MARK: Layout and update views

    override public func layoutSubviews() {
        super.layoutSubviews()

        let screenTop: CGFloat
        let toolbarMargins: UIEdgeInsets
        if canGoBack {
            UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Slide)
            navigationBar.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: ElloNavigationBar.Size.height)
            screenTop = navigationBar.frame.height
            statusBarUnderlay.hidden = true
            toolbarMargins = UIEdgeInsets(top: CGFloat(0), left: CGFloat(0), bottom: Size.toolbarMargins.bottom, right: Size.toolbarMargins.right)
        }
        else {
            screenTop = CGFloat(20)
            navigationBar.frame = CGRectZero
            statusBarUnderlay.hidden = false
            toolbarMargins = Size.toolbarMargins
        }

        buttonContainer.frame = CGRect(x: frame.width - toolbarMargins.right, y: screenTop + toolbarMargins.top, width: 0, height: Size.toolbarHeight + toolbarMargins.bottom)
            .growLeft(buttonContainer.frame.width)

        var buttonX = CGFloat(0)
        for view in buttonContainer.subviews {
            view.frame.size = CGSize(width: Size.toolbarHeight, height: Size.toolbarHeight)
            view.frame.origin = CGPoint(x: buttonX, y: 0)
            buttonX += Size.buttonMargin + Size.toolbarHeight
        }

        let avatarViewLeft = Size.margins.left
        let avatarViewTop = buttonContainer.frame.minY + (Size.toolbarHeight - Size.avatarHeight) / 2
        avatarButton.frame = CGRect(x: avatarViewLeft, y: avatarViewTop, width: Size.avatarHeight, height: Size.avatarHeight)
        avatarButton.layer.cornerRadius = avatarButton.frame.size.height / CGFloat(2)

        regionsTableView.frame = CGRect(x: 0, y: buttonContainer.frame.maxY, right: bounds.size.width, bottom: bounds.size.height)
        textScrollView.frame = regionsTableView.frame

        var bottomInset = Keyboard.shared().keyboardBottomInset(inView: self)
        if bottomInset == 0 {
            bottomInset = ElloTabBar.Size.height + Size.margins.bottom
        }
        else {
            bottomInset += Size.bottomTextMargin
        }

        regionsTableView.contentInset.top = Size.tableTopInset
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
        submitableRegions = [.Text("")]
        editableRegions = generateEditableRegions(submitableRegions)
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
            delegate?.omnibarSubmitted(submitableRegions)
        }
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
        if let path = currentTextPath, _ = regionsTableView.cellForRowAtIndexPath(path) {
            var currentText = textView.attributedText
            if currentText.string.characters.count == 0 {
                currentText = ElloAttributedString.style("")
                textView.typingAttributes = ElloAttributedString.attrs()
            }

            let newRegion: OmnibarRegion = .AttributedText(currentText)
            let (index, _) = editableRegions[path.row]
            if let index = index {
                submitableRegions[index] = newRegion
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
