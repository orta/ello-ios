//
//  OnboardingViewController.swift
//  Ello
//
//  Created by Colin Gray on 5/12/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public class OnboardingViewController: UIViewController {
    private var visibleViewController: UIViewController?

    public private(set) var controllerContainer: UIView = { return UIView() }()
    public private(set) var buttonContainer: UIView = { return UIView() }()
    public private(set) var skipButton: WhiteElloButton = {
        let button = WhiteElloButton()
        button.setTitle(NSLocalizedString("Skip", comment: "Skip button"), forState: .Normal)
        return button
    }()
    public private(set) var nextButton: LightElloButton = {
        let button = LightElloButton()
        button.setTitle(NSLocalizedString("Next", comment: "Next button"), forState: .Normal)
        return button
    }()

    override public func viewDidLoad() {
        super.viewDidLoad()

        buttonContainer.frame = view.bounds.fromBottom().growUp(94)
        buttonContainer.autoresizingMask = .FlexibleWidth | .FlexibleTopMargin
        view.addSubview(buttonContainer)

        controllerContainer.frame = view.bounds.shrinkUp(buttonContainer.frame.height)
        controllerContainer.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        view.insertSubview(controllerContainer, belowSubview: buttonContainer)

        let inset = CGFloat(15)
        skipButton.frame = CGRect(
            x: 0,
            y: inset,
            width: 104,
            height: buttonContainer.frame.height - 2*inset
        )
        skipButton.autoresizingMask = .FlexibleRightMargin | .FlexibleHeight
        buttonContainer.addSubview(skipButton)

        nextButton.frame = CGRect(
            x: skipButton.frame.maxX,
            y: inset,
            width: buttonContainer.frame.width - skipButton.frame.width - inset,
            height: buttonContainer.frame.height - 2*inset
        )
        nextButton.autoresizingMask = .FlexibleLeftMargin | .FlexibleHeight
        buttonContainer.addSubview(nextButton)

        let initialController = CommunitySelectionViewController()

    }

}


// MARK: Screen transitions
extension OnboardingViewController {

    public func swapViewController(newViewController: UIViewController) {
        visibleViewController?.willMoveToParentViewController(nil)
        newViewController.willMoveToParentViewController(self)

        let controller = (newViewController as? UINavigationController)?.topViewController ?? newViewController
        Tracker.sharedTracker.screenAppeared(controller.title ?? controller.readableClassName())

        controllerContainer.addSubview(newViewController.view)
        newViewController.view.frame = controllerContainer.bounds
        newViewController.view.autoresizingMask = .FlexibleHeight | .FlexibleWidth

        visibleViewController?.view.removeFromSuperview()
        visibleViewController?.removeFromParentViewController()

        addChildViewController(newViewController)

        newViewController.didMoveToParentViewController(self)

        visibleViewController = newViewController
    }

}
