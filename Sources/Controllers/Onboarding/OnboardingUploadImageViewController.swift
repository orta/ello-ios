//
//  OnboardingUploadImageViewController.swift
//  Ello
//
//  Created by Colin Gray on 5/21/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public class OnboardingUploadImageViewController: BaseElloViewController, OnboardingStep {
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
    var selectedImage: UIImage?

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

// MARK: Default images
extension OnboardingUploadImageViewController {
    func chooseCoverImageDefault() -> UIImage { return UIImage(named: "choose-header-image")! }
    func chooseAvatarImageDefault() -> UIImage { return UIImage(named: "choose-avatar-image")! }
}

// MARK: Loading the image picker controller and getting results
extension OnboardingUploadImageViewController {
    func chooseImageTapped() {
        let alert = UIImagePickerController.alertControllerForImagePicker(openImagePicker)
        alert.map { self.presentViewController($0, animated: true, completion: nil) }
    }

    private func openImagePicker(imageController: UIImagePickerController) {
        imageController.delegate = self
        self.presentViewController(imageController, animated: true, completion: nil)
    }

    public func userSetImage(image: UIImage) {
        chooseImageButton?.setTitle(NSLocalizedString("Pick Another", comment: "Pick another button"), forState: .Normal)
        onboardingViewController?.canGoNext = true
        selectedImage = image
    }

    public func userUploadFailed() {
        let message = NSLocalizedString("Oh no! Something went wrong.\n\nTry that again maybe?", comment: "Cover image upload failed during onboarding message")
        let alertController = AlertViewController(message: message)

        let action = AlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .Dark, handler: nil)
        alertController.addAction(action)

        self.presentViewController(alertController, animated: true, completion: nil)
    }
}

// MARK: UIImagePickerControllerDelegate
extension OnboardingUploadImageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public func imagePickerController(controller: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        if let orientedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            orientedImage.copyWithCorrectOrientationAndSize() { image in
                self.userSetImage(image)
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }

    public func imagePickerControllerDidCancel(controller: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }

}
