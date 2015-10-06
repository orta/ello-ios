//
//  CoverImageSelectionViewController.swift
//  Ello
//
//  Created by Colin Gray on 5/15/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public class CoverImageSelectionViewController: OnboardingUploadImageViewController {
    var onboardingHeader: UIView?

    override public func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Onboarding Cover Image Selection"

        setupOnboardingHeader()
        setupChooseCoverImage()
        setupChooseImageButton()
    }

    public override func onboardingWillProceed(proceed: (OnboardingData?) -> Void) {
        if let image = selectedImage {
            self.userUploadImage(image, proceed: proceed)
        }
        else {
            proceed(onboardingData)
        }
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let chooseCoverImage = chooseCoverImageDefault()
        let width = min(view.frame.width, Size.maxWidth)
        let aspect = width / chooseCoverImage.size.width

        onboardingHeader!.frame.size.width = view.frame.width
        onboardingHeader!.sizeToFit()

        chooseCoverImageView!.frame = CGRect(
            x: (view.frame.width - width) / 2,
            y: onboardingHeader!.frame.maxY + 23,
            width: width,
            height: chooseCoverImage.size.height * aspect
            )

        let chooseWidth = width - 30
        chooseImageButton!.frame = CGRect(
            x: (view.frame.width - chooseWidth) / 2,
            y: chooseCoverImageView!.frame.maxY + 23,
            width: chooseWidth,
            height: 50
            )
    }

}

// MARK: View setup
private extension CoverImageSelectionViewController {

    func setupOnboardingHeader() {
        let onboardingHeader = OnboardingHeaderView(frame: CGRect(
            x: 0,
            y: 0,
            width: view.frame.width,
            height: 0
            ))
        let header = NSLocalizedString("Customize your profile.", comment: "Header Image Selection text")
        let message = NSLocalizedString("This is what other people will see when viewing your profile, make it look good!", comment: "Header Image Selection text")
        onboardingHeader.header = header
        onboardingHeader.message = message
        onboardingHeader.autoresizingMask = [.FlexibleRightMargin, .FlexibleBottomMargin]
        onboardingHeader.sizeToFit()
        view.addSubview(onboardingHeader)
        self.onboardingHeader = onboardingHeader
    }

    func setupChooseCoverImage() {
        let chooseCoverImage = chooseCoverImageDefault()
        let width = min(view.frame.width, Size.maxWidth)
        let aspect = width / chooseCoverImage.size.width
        let chooseCoverImageView = UIImageView(frame: CGRect(
            x: (view.frame.width - width) / 2,
            y: onboardingHeader!.frame.maxY + 23,
            width: width,
            height: chooseCoverImage.size.height * aspect
            ))
        chooseCoverImageView.contentMode = .ScaleAspectFill
        chooseCoverImageView.clipsToBounds = true
        chooseCoverImageView.autoresizingMask = [.FlexibleLeftMargin, .FlexibleRightMargin, .FlexibleBottomMargin]
        chooseCoverImageView.image = chooseCoverImage
        view.addSubview(chooseCoverImageView)
        self.chooseCoverImageView = chooseCoverImageView
    }

    func setupChooseImageButton() {
        let width = min(view.frame.width, Size.maxWidth)
        let chooseWidth = width - 30
        let chooseImageButton = ElloButton(frame: CGRect(
            x: (view.frame.width - chooseWidth) / 2,
            y: chooseCoverImageView!.frame.maxY + 23,
            width: chooseWidth,
            height: 50
            ))
        chooseImageButton.autoresizingMask = [.FlexibleLeftMargin, .FlexibleRightMargin, .FlexibleBottomMargin]
        chooseImageButton.setTitle(NSLocalizedString("Choose Your Header", comment: "Choose your header button"), forState: .Normal)
        chooseImageButton.addTarget(self, action: Selector("chooseImageTapped"), forControlEvents: .TouchUpInside)
        view.addSubview(chooseImageButton)
        self.chooseImageButton = chooseImageButton
    }

}

extension CoverImageSelectionViewController {

    override public func userSetImage(image: UIImage) {
        chooseCoverImageView?.image = image
        super.userSetImage(image)
    }

    public func userUploadImage(image: UIImage, proceed: (OnboardingData?) -> Void) {
        ElloHUD.showLoadingHud()

        ProfileService().updateUserCoverImage(image, success: { (url, _) in
            ElloHUD.hideLoadingHud()
            if let user = self.currentUser {
                let asset = Asset(image: image, url: url)
                user.coverImage = asset
            }

            self.onboardingData?.coverImage = image
            proceed(self.onboardingData)
        }, failure: { _, _ in
            ElloHUD.hideLoadingHud()
            self.userUploadFailed()
        })
    }

    override public func userUploadFailed() {
        chooseCoverImageView?.image = chooseCoverImageDefault()
        onboardingData?.coverImage = nil
        super.userUploadFailed()
    }

}

