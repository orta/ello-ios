//
//  AvatarImageSelectionViewController.swift
//  Ello
//
//  Created by Colin Gray on 5/18/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public class AvatarImageSelectionViewController: BaseElloViewController, OnboardingStep {
    weak var onboardingViewController: OnboardingViewController?
    var onboardingData: OnboardingData? {
        didSet {
            if let image = onboardingData?.coverImage {
                chooseCoverImageView?.image = image
            }
            if let image = onboardingData?.avatarImage {
                chooseAvatarImageView?.image = image
            }
        }
    }
    var chooseCoverImageView: UIImageView?
    var chooseAvatarImageView: UIImageView?
    var chooseImageButton: UIButton?

    override public func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Onboarding Avatar Image Selection"

        setupChooseCoverImage()
        setupChooseAvatarImage()
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

public extension AvatarImageSelectionViewController {
    public func onboardingWillProceed() {
        println("=============== \(__FILE__.lastPathComponent) line \(__LINE__) ===============")
    }
}

// MARK: View setup
private extension AvatarImageSelectionViewController {

    private func setupChooseCoverImage() {
        let chooseCoverImage = UIImage(named: "choose-header-image")!
        let aspect = view.frame.width / chooseCoverImage.size.width
        let chooseCoverImageView = UIImageView(frame: CGRect(
            x: 0,
            y: 0,
            width: view.frame.width,
            height: chooseCoverImage.size.height * aspect
            ))
        chooseCoverImageView.contentMode = .ScaleAspectFill
        chooseCoverImageView.clipsToBounds = true
        chooseCoverImageView.autoresizingMask = .FlexibleLeftMargin | .FlexibleRightMargin | .FlexibleBottomMargin
        chooseCoverImageView.image = onboardingData?.coverImage ?? chooseCoverImage
        view.addSubview(chooseCoverImageView)
        self.chooseCoverImageView = chooseCoverImageView
    }

    private func setupChooseAvatarImage() {
        let chooseAvatarImage = UIImage(named: "choose-avatar-image")!
        let scale = view.frame.width / CGFloat(375)
        let chooseAvatarImageView = UIImageView(frame: CGRect(
            x: 17.5 * scale,
            y: chooseCoverImageView!.frame.maxY - 65,
            width: chooseAvatarImage.size.width * scale,
            height: chooseAvatarImage.size.height * scale
            ))
        chooseAvatarImageView.autoresizingMask = .FlexibleBottomMargin | .FlexibleRightMargin
        chooseAvatarImageView.image = onboardingData?.avatarImage ?? chooseAvatarImage
        chooseAvatarImageView.clipsToBounds = true
        chooseAvatarImageView.layer.cornerRadius = chooseAvatarImageView.frame.size.width / 2
        chooseAvatarImageView.contentMode = .ScaleAspectFill
        view.addSubview(chooseAvatarImageView)
        self.chooseAvatarImageView = chooseAvatarImageView
    }

    private func setupChooseImageButton() {
        let chooseImageButton = ElloButton(frame: CGRect(
            x: 0,
            y: chooseAvatarImageView!.frame.maxY + 24,
            width: view.frame.width,
            height: 90
            ).inset(all: 15))
        chooseImageButton.autoresizingMask = .FlexibleLeftMargin | .FlexibleRightMargin | .FlexibleBottomMargin
        chooseImageButton.setTitle(NSLocalizedString("Pick an Avatar", comment: "Pick an avatar button"), forState: .Normal)
        chooseImageButton.addTarget(self, action: Selector("chooseHeaderTapped"), forControlEvents: .TouchUpInside)
        view.addSubview(chooseImageButton)
        self.chooseImageButton = chooseImageButton
    }

}

extension AvatarImageSelectionViewController {

    @objc
    func chooseHeaderTapped() {
        let alert = UIImagePickerController.alertControllerForImagePicker(openImagePicker)
        alert.map { self.presentViewController($0, animated: true, completion: nil) }
    }

    private func openImagePicker(imageController : UIImagePickerController) {
        imageController.delegate = self
        self.presentViewController(imageController, animated: true, completion: nil)
    }

    public func userSetCurrentImage(orientedImage: UIImage) {
        onboardingData?.avatarImage = orientedImage
        chooseAvatarImageView?.image = orientedImage
        chooseImageButton?.setTitle(NSLocalizedString("Pick Another", comment: "Pick another button"), forState: .Normal)

        onboardingViewController?.goToNextStep(onboardingData)
    }

}

extension AvatarImageSelectionViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public func imagePickerController(controller: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let oriented = image.copyWithCorrectOrientation()
            userSetCurrentImage(oriented)
        }
        dismissViewControllerAnimated(true, completion: nil)
    }

    public func imagePickerControllerDidCancel(controller: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }

}
