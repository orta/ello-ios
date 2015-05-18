//
//  HeaderImageSelectionViewController.swift
//  Ello
//
//  Created by Colin Gray on 5/15/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public class HeaderImageSelectionViewController: BaseElloViewController, OnboardingStep {
    var onboardingViewController: OnboardingViewController?
    var onboardingHeader: OnboardingHeaderView!

    override public func viewDidLoad() {
        super.viewDidLoad()

        onboardingHeader = OnboardingHeaderView(frame: CGRect(
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
        let chooseHeaderImageView = UIImageView(frame: CGRect(
            x: 0,
            y: onboardingHeader.frame.maxY + 23,
            width: view.frame.width,
            height: chooseHeaderImage.size.height * aspect
            ))
        chooseHeaderImageView.autoresizingMask = .FlexibleLeftMargin | .FlexibleRightMargin | .FlexibleBottomMargin
        chooseHeaderImageView.image = chooseHeaderImage
        view.addSubview(chooseHeaderImageView)

        let chooseHeaderButton = ElloButton(frame: CGRect(
            x: 0,
            y: chooseHeaderImageView.frame.maxY + 8,
            width: view.frame.width,
            height: 90
            ).inset(all: 15))
        chooseHeaderButton.autoresizingMask = .FlexibleLeftMargin | .FlexibleRightMargin | .FlexibleBottomMargin
        chooseHeaderButton.setTitle(NSLocalizedString("Choose Your Header", comment: "Choose your header button"), forState: .Normal)
        view.addSubview(chooseHeaderButton)
    }

}
