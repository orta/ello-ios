//
//  AvatarImageSelectionViewController.swift
//  Ello
//
//  Created by Colin Gray on 5/18/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public class AvatarImageSelectionViewController: OnboardingUploadImageViewController {

    override public func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Onboarding Avatar Image Selection"

        setupChooseCoverImage()
        setupChooseAvatarImage()
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

        let x = chooseCoverImageView?.frame.minX ?? CGFloat(0)
        self.chooseAvatarImageView?.frame.origin.x = x
    }

}

// MARK: View setup
private extension AvatarImageSelectionViewController {

    private func setupChooseCoverImage() {
        let chooseCoverImage = chooseCoverImageDefault()
        let width = min(view.frame.width, Size.maxWidth)
        let aspect = width / chooseCoverImage.size.width
        let chooseCoverImageView = UIImageView(frame: CGRect(
            x: (view.frame.width - width) / 2,
            y: 0,
            width: width,
            height: chooseCoverImage.size.height * aspect
            ))
        chooseCoverImageView.contentMode = .ScaleAspectFill
        chooseCoverImageView.clipsToBounds = true
        chooseCoverImageView.autoresizingMask = [.FlexibleLeftMargin, .FlexibleRightMargin, .FlexibleBottomMargin]
        chooseCoverImageView.image = onboardingData?.coverImage ?? chooseCoverImage
        view.addSubview(chooseCoverImageView)
        self.chooseCoverImageView = chooseCoverImageView
    }

    private func setupChooseAvatarImage() {
        let chooseAvatarImage = chooseAvatarImageDefault()
        let width = min(view.frame.width, Size.maxWidth)
        let scale = width / CGFloat(375)
        let x = chooseCoverImageView?.frame.minX ?? CGFloat(0)
        let chooseAvatarImageView = UIImageView(frame: CGRect(
            x: x,
            y: chooseCoverImageView!.frame.maxY - 65,
            width: chooseAvatarImage.size.width * scale,
            height: chooseAvatarImage.size.height * scale
            ))
        chooseAvatarImageView.autoresizingMask = [.FlexibleLeftMargin, .FlexibleRightMargin, .FlexibleBottomMargin]
        chooseAvatarImageView.image = onboardingData?.avatarImage ?? chooseAvatarImage
        chooseAvatarImageView.clipsToBounds = true
        chooseAvatarImageView.layer.cornerRadius = chooseAvatarImageView.frame.size.width / 2
        chooseAvatarImageView.contentMode = .ScaleAspectFill
        view.addSubview(chooseAvatarImageView)
        self.chooseAvatarImageView = chooseAvatarImageView
    }

    private func setupChooseImageButton() {
        let width = min(view.frame.width, Size.maxWidth)
        let chooseImageButton = ElloButton(frame: CGRect(
            x: (view.frame.width - width) / 2,
            y: chooseAvatarImageView!.frame.maxY + 24,
            width: width,
            height: 80
            ).inset(all: 15))
        chooseImageButton.autoresizingMask = [.FlexibleLeftMargin, .FlexibleRightMargin, .FlexibleBottomMargin]
        chooseImageButton.setTitle(NSLocalizedString("Pick an Avatar", comment: "Pick an avatar button"), forState: .Normal)
        chooseImageButton.addTarget(self, action: Selector("chooseImageTapped"), forControlEvents: .TouchUpInside)
        view.addSubview(chooseImageButton)
        self.chooseImageButton = chooseImageButton
    }

}

extension AvatarImageSelectionViewController {

    override public func userSetImage(image: UIImage) {
        chooseAvatarImageView?.image = image
        super.userSetImage(image)
    }

    public func userUploadImage(image: UIImage, proceed: (OnboardingData?) -> Void) {
        ElloHUD.showLoadingHud()

        ProfileService().updateUserAvatarImage(image, success: { (url, _) in
            ElloHUD.hideLoadingHud()
            if let user = self.currentUser {
                let asset = Asset(image: image, url: url)
                user.avatar = asset
            }

            self.onboardingData?.avatarImage = image
            proceed(self.onboardingData)
        }, failure: { _, _ in
            ElloHUD.hideLoadingHud()
            self.userUploadFailed()
        })
    }

    override public func userUploadFailed() {
        chooseAvatarImageView?.image = chooseAvatarImageDefault()
        onboardingData?.avatarImage = nil
        super.userUploadFailed()
    }

}

