//
//  AvatarImageSelectionViewController.swift
//  Ello
//
//  Created by Colin Gray on 5/18/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public class AvatarImageSelectionViewController: BaseElloViewController, OnboardingStep {
    weak var onboardingViewController: OnboardingViewController?
    var onboardingData: OnboardingData?
    var chooseAvatarImageView: UIImageView?

    override public func viewDidLoad() {
        super.viewDidLoad()

        let chooseHeaderImage = UIImage(named: "choose-header-image")!
        let aspect = view.frame.width / chooseHeaderImage.size.width
        let chooseHeaderImageView = UIImageView(frame: CGRect(
            x: 0,
            y: 0,
            width: view.frame.width,
            height: chooseHeaderImage.size.height * aspect
            ))
        chooseHeaderImageView.autoresizingMask = .FlexibleLeftMargin | .FlexibleRightMargin | .FlexibleBottomMargin
        chooseHeaderImageView.image = chooseHeaderImage
        view.addSubview(chooseHeaderImageView)

        let chooseAvatarImage = UIImage(named: "choose-avatar-image")!
        let chooseAvatarImageView = UIImageView(frame: CGRect(
            x: 17.5,
            y: chooseHeaderImageView.frame.maxY - 65,
            width: chooseAvatarImage.size.width,
            height: chooseAvatarImage.size.height
            ))
        chooseAvatarImageView.autoresizingMask = .FlexibleBottomMargin | .FlexibleRightMargin
        chooseAvatarImageView.image = chooseAvatarImage
        chooseAvatarImageView.clipsToBounds = true
        chooseAvatarImageView.layer.cornerRadius = chooseAvatarImage.size.width / 2
        chooseAvatarImageView.contentMode = .ScaleAspectFill
        view.addSubview(chooseAvatarImageView)
        self.chooseAvatarImageView = chooseAvatarImageView

        let chooseHeaderButton = ElloButton(frame: CGRect(
            x: 0,
            y: chooseAvatarImageView.frame.maxY + 24,
            width: view.frame.width,
            height: 90
            ).inset(all: 15))
        chooseHeaderButton.autoresizingMask = .FlexibleLeftMargin | .FlexibleRightMargin | .FlexibleBottomMargin
        chooseHeaderButton.setTitle(NSLocalizedString("Choose Your Header", comment: "Choose your header button"), forState: .Normal)
        chooseHeaderButton.addTarget(self, action: Selector("chooseHeaderTapped"), forControlEvents: .TouchUpInside)
        view.addSubview(chooseHeaderButton)
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

    public func userSetCurrentImage(oriented: UIImage) {
        chooseAvatarImageView?.image = oriented
        // onboardingViewController?.goToNextStep()
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
