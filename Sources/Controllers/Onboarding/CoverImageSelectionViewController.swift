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
    var chooseCoverImageView: UIImageView?
    var chooseImageButton: UIButton?

    override public func viewDidLoad() {
        super.viewDidLoad()

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

        let chooseHeaderImage = UIImage(named: "choose-header-image")!
        let aspect = view.frame.width / chooseHeaderImage.size.width
        let chooseCoverImageView = UIImageView(frame: CGRect(
            x: 0,
            y: onboardingHeader.frame.maxY + 23,
            width: view.frame.width,
            height: chooseHeaderImage.size.height * aspect
            ))
        chooseCoverImageView.contentMode = .ScaleAspectFill
        chooseCoverImageView.clipsToBounds = true
        chooseCoverImageView.autoresizingMask = .FlexibleLeftMargin | .FlexibleRightMargin | .FlexibleBottomMargin
        chooseCoverImageView.image = chooseHeaderImage
        view.addSubview(chooseCoverImageView)
        self.chooseCoverImageView = chooseCoverImageView

        let chooseImageButton = ElloButton(frame: CGRect(
            x: 0,
            y: chooseCoverImageView.frame.maxY + 8,
            width: view.frame.width,
            height: 90
            ).inset(all: 15))
        chooseImageButton.autoresizingMask = .FlexibleLeftMargin | .FlexibleRightMargin | .FlexibleBottomMargin
        chooseImageButton.setTitle(NSLocalizedString("Choose Your Header", comment: "Choose your header button"), forState: .Normal)
        chooseImageButton.addTarget(self, action: Selector("chooseHeaderTapped"), forControlEvents: .TouchUpInside)
        view.addSubview(chooseImageButton)
        self.chooseImageButton = chooseImageButton
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
        onboardingData?.coverImage = orientedImage
        onboardingViewController?.goToNextStep(onboardingData)
    }

}

extension CoverImageSelectionViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
