//
//  CoverImageSelectionViewController.swift
//  Ello
//
//  Created by Colin Gray on 5/15/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public class CoverImageSelectionViewController: BaseElloViewController, OnboardingStep {
    weak var onboardingViewController: OnboardingViewController?
    var onboardingData: OnboardingData? {
        didSet {
            if let image = onboardingData?.coverImage {
                chooseCoverImageView?.image = image
            }
        }
    }
    var onboardingHeader: UIView?
    var chooseCoverImageView: UIImageView?
    var chooseImageButton: UIButton?

    override public func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Onboarding Cover Image Selection"

        setupOnboardingHeader()
        setupChooseHeaderImage()
        setupChooseImageButton()
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let button = chooseImageButton {
            let bottomMargin = CGFloat(10)
            if button.frame.maxY + bottomMargin > view.frame.height {
                button.frame.origin.y = view.frame.height - (button.frame.height + bottomMargin)
            }
        }
    }

}

// MARK: View setup
private extension CoverImageSelectionViewController {
    private func chooseCoverImageDefault() -> UIImage { return UIImage(named: "choose-header-image")! }
    private func chooseAvatarImageDefault() -> UIImage { return UIImage(named: "choose-avatar-image")! }

    func setupOnboardingHeader() {
        let onboardingHeader = OnboardingHeaderView(frame: CGRect(
            x: 0,
            y: 0,
            width: view.frame.width,
            height: 0
            ))
        onboardingHeader.autoresizingMask = .FlexibleWidth
        let header = NSLocalizedString("Customize your profile.", comment: "Header Image Selection text")
        let message = NSLocalizedString("This is what other people will see when viewing your profile, make it look good!", comment: "Header Image Selection text")
        onboardingHeader.header = header
        onboardingHeader.message = message
        onboardingHeader.autoresizingMask = .FlexibleWidth | .FlexibleBottomMargin
        onboardingHeader.sizeToFit()
        view.addSubview(onboardingHeader)
        self.onboardingHeader = onboardingHeader
    }

    func setupChooseHeaderImage() {
        let chooseHeaderImage = chooseCoverImageDefault()
        let aspect = view.frame.width / chooseHeaderImage.size.width
        let chooseCoverImageView = UIImageView(frame: CGRect(
            x: 0,
            y: onboardingHeader!.frame.maxY + 23,
            width: view.frame.width,
            height: chooseHeaderImage.size.height * aspect
            ))
        chooseCoverImageView.contentMode = .ScaleAspectFill
        chooseCoverImageView.clipsToBounds = true
        chooseCoverImageView.autoresizingMask = .FlexibleLeftMargin | .FlexibleRightMargin | .FlexibleBottomMargin
        chooseCoverImageView.image = chooseHeaderImage
        view.addSubview(chooseCoverImageView)
        self.chooseCoverImageView = chooseCoverImageView
    }

    func setupChooseImageButton() {
        let chooseImageButton = ElloButton(frame: CGRect(
            x: 0,
            y: chooseCoverImageView!.frame.maxY + 8,
            width: view.frame.width,
            height: 90
            ).inset(all: 15))
        chooseImageButton.autoresizingMask = .FlexibleLeftMargin | .FlexibleRightMargin | .FlexibleBottomMargin
        chooseImageButton.setTitle(NSLocalizedString("Choose Your Header", comment: "Choose your header button"), forState: .Normal)
        chooseImageButton.addTarget(self, action: Selector("chooseHeaderTapped"), forControlEvents: .TouchUpInside)
        view.addSubview(chooseImageButton)
        self.chooseImageButton = chooseImageButton
    }

}

extension CoverImageSelectionViewController {
    func chooseHeaderTapped() {
        let alert = UIImagePickerController.alertControllerForImagePicker(openImagePicker)
        alert.map { self.presentViewController($0, animated: true, completion: nil) }
    }

    private func openImagePicker(imageController : UIImagePickerController) {
        imageController.delegate = self
        self.presentViewController(imageController, animated: true, completion: nil)
    }

    public func userSetImage(image: UIImage) {
        chooseCoverImageView?.image = image
        chooseImageButton?.setTitle(NSLocalizedString("Pick Another", comment: "Pick another button"), forState: .Normal)
        ElloHUD.showLoadingHud()
    }

    public func userUploadImage(image: UIImage) {
        onboardingData?.coverImage = image

        ProfileService().updateUserCoverImage(image, success: { _ in
            ElloHUD.hideLoadingHud()
            self.onboardingViewController?.goToNextStep(self.onboardingData)
        }) { _, _ in
            ElloHUD.hideLoadingHud()
            self.chooseCoverImageView?.image = self.chooseCoverImageDefault()
            self.onboardingData?.coverImage = nil

            let message = NSLocalizedString("Oh no! Something went wrong.\n\nTry that again maybe?", comment: "Cover image upload failed during onboarding message")
            let alertController = AlertViewController(message: message)

            let action = AlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .Dark, handler: nil)
            alertController.addAction(action)

            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
}

extension CoverImageSelectionViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public func imagePickerController(controller: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        let orientedImage = (info[UIImagePickerControllerOriginalImage] as? UIImage)?.copyWithCorrectOrientation()
        if let orientedImage = orientedImage {
            userSetImage(orientedImage)
        }

        dismissViewControllerAnimated(true) {
            if let orientedImage = orientedImage {
                self.userUploadImage(orientedImage)
            }
        }
    }

    public func imagePickerControllerDidCancel(controller: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }

}
