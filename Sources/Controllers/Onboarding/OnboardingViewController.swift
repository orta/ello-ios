//
//  OnboardingViewController.swift
//  Ello
//
//  Created by Colin Gray on 5/12/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

protocol OnboardingStep {
    var onboardingViewController: OnboardingViewController? { get set }
}


public class OnboardingViewController: BaseElloViewController, HasAppController {
    var parentAppController: AppViewController?
    var isTransitioning = false
    private var visibleViewController: UIViewController?
    private var visibleViewControllerIndex: Int = 0
    private var onboardingViewControllers = [UIViewController]()

    public private(set) lazy var controllerContainer: UIView = { return UIView() }()
    public private(set) lazy var buttonContainer: UIView = { return UIView() }()
    public private(set) lazy var skipButton: ClearElloButton = {
        let button = ClearElloButton()
        button.setTitle(NSLocalizedString("Skip", comment: "Skip button"), forState: .Normal)
        return button
    }()
    public private(set) lazy var nextButton: LightElloButton = {
        let button = LightElloButton()
        button.setTitle(NSLocalizedString("Next", comment: "Next button"), forState: .Normal)
        return button
    }()
    public var canGoNext: Bool {
        get { return nextButton.enabled }
        set { return nextButton.enabled = newValue }
    }

    override func didSetCurrentUser() {
        super.didSetCurrentUser()
        for controller in onboardingViewControllers {
            if let controller = onboardingViewControllers as? ControllerThatMightHaveTheCurrentUser {
                controller.currentUser = currentUser
            }
        }
    }

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
            x: inset,
            y: inset,
            width: 89,
            height: buttonContainer.frame.height - 2*inset
        )
        skipButton.autoresizingMask = .FlexibleRightMargin | .FlexibleHeight
        skipButton.addTarget(self, action: Selector("goToNextStep"), forControlEvents: .TouchUpInside)
        buttonContainer.addSubview(skipButton)

        nextButton.frame = CGRect(
            x: skipButton.frame.maxX + inset,
            y: inset,
            width: buttonContainer.frame.width - skipButton.frame.maxX - 2*inset,
            height: buttonContainer.frame.height - 2*inset
        )
        nextButton.autoresizingMask = .FlexibleLeftMargin | .FlexibleHeight
        nextButton.addTarget(self, action: Selector("goToNextStep"), forControlEvents: .TouchUpInside)
        buttonContainer.addSubview(nextButton)

        // let communityController = CommunitySelectionViewController()
        // communityController.onboardingViewController = self
        // communityController.currentUser = currentUser
        // addOnboardingViewController(communityController)

        // let awesomePeopleController = AwesomePeopleSelectionViewController()
        // awesomePeopleController.onboardingViewController = self
        // awesomePeopleController.currentUser = currentUser
        // addOnboardingViewController(awesomePeopleController)

        // let foundersController = FoundersSelectionViewController()
        // foundersController.onboardingViewController = self
        // foundersController.currentUser = currentUser
        // addOnboardingViewController(foundersController)

        // let importPromptController = ImportPromptViewController()
        // importPromptController.onboardingViewController = self
        // importPromptController.currentUser = currentUser
        // addOnboardingViewController(importPromptController)

        let headerImageSelectionController = HeaderImageSelectionViewController()
        headerImageSelectionController.onboardingViewController = self
        headerImageSelectionController.currentUser = currentUser
        addOnboardingViewController(headerImageSelectionController)

        let avatarImageSelectionController = AvatarImageSelectionViewController()
        avatarImageSelectionController.onboardingViewController = self
        avatarImageSelectionController.currentUser = currentUser
        addOnboardingViewController(avatarImageSelectionController)
    }

}


// MARK: Screen transitions
extension OnboardingViewController {

    private func showFirstViewController(viewController: UIViewController) {
        Tracker.sharedTracker.screenAppeared(viewController.title ?? viewController.readableClassName())

        addChildViewController(viewController)
        controllerContainer.addSubview(viewController.view)
        viewController.view.frame = controllerContainer.bounds
        viewController.view.autoresizingMask = .FlexibleHeight | .FlexibleWidth
        viewController.didMoveToParentViewController(self)

        visibleViewController = viewController
        visibleViewControllerIndex = 0
        onboardingViewControllers.append(viewController)
    }

    private func addOnboardingViewController(viewController: UIViewController) {
        if visibleViewController == nil {
            showFirstViewController(viewController)
        }
        else {
            onboardingViewControllers.append(viewController)
        }
    }

    public func goToNextStep() {
        self.visibleViewControllerIndex += 1

        // <debugging start over at first step>
        if self.visibleViewControllerIndex == count(self.onboardingViewControllers) {
            self.visibleViewControllerIndex = 0
        }
        // </debugging>

        if let nextViewController = onboardingViewControllers.safeValue(visibleViewControllerIndex)
        {
            goToController(nextViewController)
        }
        else {
            // DONE!
        }
    }

    public func goToController(viewController: UIViewController) {
        if let visibleViewController = visibleViewController {
            transitionFromViewController(visibleViewController, toViewController: viewController)
        }
    }

    private func transitionFromViewController(visibleViewController: UIViewController, toViewController nextViewController: UIViewController) {
        if isTransitioning {
            return
        }

        Tracker.sharedTracker.screenAppeared(nextViewController.title ?? nextViewController.readableClassName())
        visibleViewController.willMoveToParentViewController(nil)
        addChildViewController(nextViewController)

        nextViewController.view.alpha = 1
        nextViewController.view.frame = CGRect(
            x: controllerContainer.frame.width,
            y: 0,
            width: controllerContainer.frame.width,
            height: controllerContainer.frame.height
        )

        isTransitioning = true
        transitionFromViewController(visibleViewController,
            toViewController: nextViewController,
            duration: 0.4,
            options: UIViewAnimationOptions(0),
            animations: {
                self.controllerContainer.insertSubview(nextViewController.view, aboveSubview: visibleViewController.view)
                visibleViewController.view.frame.origin.x = -visibleViewController.view.frame.width
                nextViewController.view.frame.origin.x = 0
            },
            completion: { _ in
                nextViewController.didMoveToParentViewController(self)
                visibleViewController.removeFromParentViewController()
                self.visibleViewController = nextViewController
                self.isTransitioning = false
            })
    }

}
