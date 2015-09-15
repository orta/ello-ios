//
//  SettingsViewController.swift
//  Ello
//
//  Created by Tony DiPasquale on 3/19/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

public enum SettingsRow: Int {
    case CoverImage
    case AvatarImage
    case ProfileDescription
    case CredentialSettings
    case Name
    case Bio
    case Links
    case PreferenceSettings
    case Unknown
}


public class SettingsContainerViewController: BaseElloViewController {
    weak public var elloNavBar: ElloNavigationBar!
    @IBOutlet weak var navigationBarTopConstraint: NSLayoutConstraint!
    public var navBarsVisible: Bool = true
    private var settingsViewController: SettingsViewController?

    func showNavBars() {
        navigationBarTopConstraint.constant = 0
        animate {
            UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Slide)
            self.view.layoutIfNeeded()
        }

        if let tableView = settingsViewController?.tableView {
            tableView.contentInset.bottom = ElloTabBar.Size.height
            tableView.scrollIndicatorInsets.bottom = ElloTabBar.Size.height
        }
    }

    func hideNavBars() {
        navigationBarTopConstraint.constant = -ElloNavigationBar.Size.height - 1
        animate {
            UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .Slide)
            self.view.layoutIfNeeded()
        }

        if let tableView = settingsViewController?.tableView {
            tableView.contentInset.bottom = 0
            tableView.scrollIndicatorInsets.bottom = 0
        }
    }

    public override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SettingsContainerSegue" {
            let settings = segue.destinationViewController as! SettingsViewController
            settings.currentUser = currentUser
            settingsViewController = settings
            if navBarsVisible {
                showNavBars()
            }
            else {
                hideNavBars()
            }
            elloNavBar.items = [settings.navigationItem]
            settings.scrollLogic.isShowing = navBarsVisible
        }
    }

    override func didSetCurrentUser() {
        settingsViewController?.currentUser = currentUser
    }

    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        let hidden = elloTabBarController?.tabBarHidden ?? UIApplication.sharedApplication().statusBarHidden
        UIApplication.sharedApplication().setStatusBarHidden(hidden, withAnimation: .Slide)
    }
}


public class SettingsViewController: UITableViewController, ControllerThatMightHaveTheCurrentUser {

    @IBOutlet weak public var avatarImageView: UIView!
    weak public var profileDescription: ElloLabel!
    @IBOutlet weak public var coverImage: UIImageView!
    @IBOutlet weak public var avatarImage: UIImageView!
    var scrollLogic: ElloScrollLogic!

    weak public var nameTextFieldView: ElloTextFieldView!
    weak public var linksTextFieldView: ElloTextFieldView!
    @IBOutlet weak public var bioTextView: ElloEditableTextView!
    weak public var bioTextCountLabel: ElloErrorLabel!
    @IBOutlet weak public var bioTextStatusImage: UIImageView!

    private var bioTextViewDidChange: (() -> Void)?

    public var currentUser: User? {
        didSet {
            credentialSettingsViewController?.currentUser = currentUser
            dynamicSettingsViewController?.currentUser = currentUser
        }
    }

    var credentialSettingsViewController: CredentialSettingsViewController?
    var dynamicSettingsViewController: DynamicSettingsViewController?
    var photoSaveCallback: (UIImage -> Void)?

    override public func awakeFromNib() {
        super.awakeFromNib()
        setupNavigationBar()
        scrollLogic = ElloScrollLogic(
            onShow: self.showNavBars,
            onHide: self.hideNavBars
        )
    }

    var elloTabBarController: ElloTabBarController? {
        return findViewController { vc in vc is ElloTabBarController } as! ElloTabBarController?
    }
    var containerController: SettingsContainerViewController? {
        return findViewController { vc in vc is SettingsContainerViewController } as! SettingsContainerViewController?
    }

    func showNavBars(scrollToBottom : Bool) {
        if let tabBarController = self.elloTabBarController {
            tabBarController.setTabBarHidden(false, animated: true)
        }

        containerController?.showNavBars()
    }

    func hideNavBars() {
        if let tabBarController = self.elloTabBarController {
            tabBarController.setTabBarHidden(true, animated: true)
        }

        containerController?.hideNavBars()
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        ElloHUD.showLoadingHud()
        setupViews()
    }

    private func setupViews() {
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
        containerController?.showNavBars()
        setupProfileDescription()
        setupDefaultValues()
    }

    private func setupProfileDescription() {
        let profileDescriptionAttributedText = profileDescription.attributedText ?? NSAttributedString(string: "")
        let text = NSMutableAttributedString(attributedString: profileDescriptionAttributedText)

        text.addAttribute(NSForegroundColorAttributeName, value: UIColor.greyA(), range: NSRange(location: 0, length: text.length))
        profileDescription.attributedText = text
    }

    private func setupNavigationBar() {
        let backItem = UIBarButtonItem.backChevronWithTarget(self, action: Selector("backAction"))
        navigationItem.leftBarButtonItem = backItem
        navigationItem.title = NSLocalizedString("Edit Profile", comment: "Edit Profile Screen Title")
        navigationItem.fixNavBarItemPadding()
    }

    private func setupDefaultValues() {
        if let cachedImage = TemporaryCache.load(.CoverImage) {
            coverImage.image = cachedImage
        }
        else if let imageURL = currentUser?.coverImageURL {
            coverImage.pin_setImageFromURL(imageURL)
        }

        if let cachedImage = TemporaryCache.load(.Avatar) {
            avatarImage.image = cachedImage
        }
        else if let imageURL = currentUser?.avatar?.large?.url {
            avatarImage.pin_setImageFromURL(imageURL)
        }

        nameTextFieldView.label.setLabelText(NSLocalizedString("Name", comment: "name setting"))
        nameTextFieldView.textField.text = currentUser?.name

        let updateNameFunction = debounce(0.5) { [unowned self] in
            let name = self.nameTextFieldView.textField.text ?? ""
            ProfileService().updateUserProfile(["name": name], success: { user in
                if let nav = self.navigationController as? ElloNavigationController {
                    nav.setProfileData(user)
                    self.nameTextFieldView.setState(.OK)
                } else {
                    self.nameTextFieldView.setState(.Error)
                }
            }, failure: { _, _ in
                self.nameTextFieldView.setState(.Error)
            })
        }

        nameTextFieldView.textFieldDidChange = { _ in
            self.nameTextFieldView.setState(.Loading)
            updateNameFunction()
        }

        linksTextFieldView.label.setLabelText(NSLocalizedString("Links", comment: "links setting"))
        linksTextFieldView.textField.keyboardType = UIKeyboardType.URL
        if let user = currentUser, let links = user.externalLinksList {
            var urls = [String]()
            for link in links {
                if let url = link["url"] {
                    urls.append(url)
                }
            }
            linksTextFieldView.textField.text = urls.joinWithSeparator(", ")
        }

        let updateLinksFunction = debounce(0.5) { [unowned self] in
            let links = self.linksTextFieldView.textField.text ?? ""
            ProfileService().updateUserProfile(["external_links": links], success: { user in
                if let nav = self.navigationController as? ElloNavigationController {
                    nav.setProfileData(user)
                    self.linksTextFieldView.setState(.OK)
                } else {
                    self.linksTextFieldView.setState(.Error)
                }
            }, failure: { _, _ in
                self.linksTextFieldView.setState(.Error)
            })
        }

        linksTextFieldView.textFieldDidChange = { _ in
            self.linksTextFieldView.setState(.Loading)
            updateLinksFunction()
        }

        bioTextView.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 30)
        bioTextView.text = currentUser?.profile?.shortBio
        bioTextView.delegate = self

        bioTextViewDidChange = debounce(0.5) { [unowned self] in
            let bio = self.bioTextView.text
            ProfileService().updateUserProfile(["unsanitized_short_bio": bio], success: { user in
                if let nav = self.navigationController as? ElloNavigationController {
                    nav.setProfileData(user)
                    self.bioTextStatusImage.image = ValidationState.OK.imageRepresentation
                } else {
                    self.bioTextStatusImage.image = ValidationState.Error.imageRepresentation
                }
            }, failure: { _, _ in
                self.bioTextStatusImage.image = ValidationState.Error.imageRepresentation
            })
        }
    }

    func backAction() {
        navigationController?.popViewControllerAnimated(true)
    }

    override public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch SettingsRow(rawValue: indexPath.row) ?? .Unknown {
        case .CoverImage: return 200
        case .AvatarImage: return 250
        case .ProfileDescription: return 130
        case .CredentialSettings: return credentialSettingsViewController?.height ?? 0
        case .Name: return nameTextFieldView.height
        case .Bio: return 200
        case .Links: return linksTextFieldView.height
        case .PreferenceSettings: return dynamicSettingsViewController?.height ?? 0
        case .Unknown: return 0
        }
    }

    override public func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier ?? "" {
        case "CredentialSettingsSegue":
            credentialSettingsViewController = segue.destinationViewController as? CredentialSettingsViewController
            credentialSettingsViewController?.currentUser = currentUser
            credentialSettingsViewController?.delegate = self

        case "DynamicSettingsSegue":
            dynamicSettingsViewController = segue.destinationViewController as? DynamicSettingsViewController
            dynamicSettingsViewController?.currentUser = currentUser

        default: break
        }
    }

    @IBAction func logOutTapped(sender: ElloTextButton) {
        Tracker.sharedTracker.tappedLogout()
        postNotification(AuthenticationNotifications.userLoggedOut, value: ())
    }

    @IBAction func coverImageTapped() {
        photoSaveCallback = { image in
            ElloHUD.showLoadingHud()
            ProfileService().updateUserCoverImage(image, success: { url, _ in
                ElloHUD.hideLoadingHud()
                if let user = self.currentUser {
                    let asset = Asset(image: image, url: url)
                    user.coverImage = asset

                    postNotification(CurrentUserChangedNotification, value: user)
                }
                self.coverImage.image = image
                self.alertUserOfImageProcessing()
            }, failure: { _, _ in
                ElloHUD.hideLoadingHud()
            })
        }
        openImagePicker()
    }

    @IBAction func avatarImageTapped() {
        photoSaveCallback = { image in
            ElloHUD.showLoadingHud()

            ProfileService().updateUserAvatarImage(image, success: { url, _ in
                ElloHUD.hideLoadingHud()
                if let user = self.currentUser {
                    let asset = Asset(image: image, url: url)
                    user.avatar = asset

                    postNotification(CurrentUserChangedNotification, value: user)
                }
                self.avatarImage.image = image
                self.alertUserOfImageProcessing()
            }, failure: { _, _ in
                ElloHUD.hideLoadingHud()
            })
        }
        openImagePicker()
    }

    private func openImagePicker() {
        let alertViewController = UIImagePickerController.alertControllerForImagePicker { imagePicker in
            imagePicker.delegate = self
            self.presentViewController(imagePicker, animated: true, completion: .None)
        }

        if let alertViewController = alertViewController {
            logPresentingAlert("SettingsViewController")
            presentViewController(alertViewController, animated: true, completion: .None)
        }
    }

    private func alertUserOfImageProcessing() {
        let message = NSLocalizedString("You’ve updated your Avatar/Header.\n\nIt may take a few minutes for your new avatar/header to appear on Ello, so please be patient. It’ll be live soon!", comment: "Settings image updated copy")
        let alertController = AlertViewController(message: message)
        let action = AlertAction(title: NSLocalizedString("OK", comment: "ok"), style: .Light, handler: .None)
        alertController.addAction(action)
        logPresentingAlert("SettingsViewController")
        presentViewController(alertController, animated: true, completion: .None)
    }
}

extension SettingsViewController: CredentialSettingsDelegate {
    public func credentialSettingsDidUpdate() {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}

extension SettingsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    public func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            image.copyWithCorrectOrientationAndSize() { image in
                self.photoSaveCallback?(image)
                self.dismissViewControllerAnimated(true, completion: .None)
            }
        }
        else {
            self.dismissViewControllerAnimated(true, completion: .None)
        }
    }

    public func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: .None)
    }
}

public extension SettingsViewController {
    class func instantiateFromStoryboard() -> SettingsViewController {
        return UIStoryboard(name: "Settings", bundle: NSBundle(forClass: AppDelegate.self)).instantiateInitialViewController() as! SettingsViewController
    }
}

extension SettingsViewController: UITextViewDelegate {
    public func textViewDidChange(textView: UITextView) {
        let characterCount = textView.text.lengthOfBytesUsingEncoding(NSASCIIStringEncoding)
        bioTextCountLabel.setLabelText("\(characterCount)")
        bioTextCountLabel.hidden = characterCount <= 192
        bioTextStatusImage.image = ValidationState.Loading.imageRepresentation
        bioTextViewDidChange?()
    }
}


// strangely, we have to "override" these delegate methods, but the parent class
// UITableViewController doesn't implement them.
extension SettingsViewController {

    public override func scrollViewDidScroll(scrollView: UIScrollView) {
        scrollLogic.scrollViewDidScroll(scrollView)
    }

    public override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        scrollLogic.scrollViewWillBeginDragging(scrollView)
    }

    public override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate: Bool) {
        scrollLogic.scrollViewDidEndDragging(scrollView, willDecelerate: willDecelerate)
    }

}
