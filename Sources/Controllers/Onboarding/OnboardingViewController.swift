//
//  OnboardingViewController.swift
//  Ello
//
//  Created by Colin Gray on 5/12/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

@objc
protocol OnboardingStep {
    var onboardingViewController: OnboardingViewController? { get set }
    var onboardingData: OnboardingData? { get set }
    optional func onboardingWillProceed((OnboardingData?) -> Void)
    optional func onboardingStepBegin()
}


@objc
public class OnboardingData {
    var communityFollows: [User] = []
    var coverImage: UIImage? = nil
    var avatarImage: UIImage? = nil
}

private enum OnboardingDirection: CGFloat {
    case Left = -1
    case Right = 1
}


public class OnboardingViewController: BaseElloViewController, HasAppController {
    public struct Size {
        static let buttonContainerHeight = CGFloat(80)
    }

    var parentAppController: AppViewController?
    var isTransitioning = false
    private var visibleViewController: UIViewController?
    private var visibleViewControllerIndex: Int = 0
    private var onboardingViewControllers = [UIViewController]()
    var onboardingData: OnboardingData?

    public private(set) lazy var controllerContainer: UIView = { return UIView() }()
    public private(set) lazy var buttonContainer: UIView = { return UIView() }()
    public private(set) lazy var skipButton: OnboardingSkipButton = {
        let button = OnboardingSkipButton()
        return button
    }()
    public private(set) lazy var nextButton: OnboardingNextButton = {
        let button = OnboardingNextButton()
        button.setTitle(NSLocalizedString("Next", comment: "Next button"), forState: .Normal)
        return button
    }()
    public var canGoNext: Bool {
        get { return nextButton.enabled }
        set { if nextButton.enabled != newValue { nextButton.enabled = newValue } }
    }

    override func didSetCurrentUser() {
        super.didSetCurrentUser()
        for controller in onboardingViewControllers {
            if let controller = onboardingViewControllers as? ControllerThatMightHaveTheCurrentUser {
                controller.currentUser = currentUser
            }
        }
    }

    required public init() {
        super.init(nibName: nil, bundle: NSBundle(forClass: ProfileInfoViewController.self))
        modalTransitionStyle = .CrossDissolve
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .whiteColor()

        setupButtonContainer()
        setupControllerContainer()
        setupOnboardingControllers()
    }

}

// MARK: Button Actions
extension OnboardingViewController {

    public func proceedToNextStep() {
        let proceedClosure: (OnboardingData?) -> Void = { data in
            self.onboardingData = data
            self.goToNextStep(data)
        }

        if let onboardingStep = visibleViewController as? OnboardingStep,
            let proceed = onboardingStep.onboardingWillProceed
        {
            proceed(proceedClosure)
        }
        else {
            proceedClosure(self.onboardingData)
        }
    }

    public func skipToNextStep() {
        goToNextStep(onboardingData)
    }

}

private extension OnboardingViewController {

    func setupButtonContainer() {
        buttonContainer.frame = view.bounds.fromBottom().growUp(Size.buttonContainerHeight)
        buttonContainer.autoresizingMask = .FlexibleWidth | .FlexibleTopMargin
        buttonContainer.backgroundColor = .whiteColor()
        view.addSubview(buttonContainer)

        let inset = CGFloat(15)
        skipButton.frame = CGRect(
            x: 0,
            y: 0,
            width: Size.buttonContainerHeight,
            height: Size.buttonContainerHeight
        ).inset(all: inset)
        skipButton.autoresizingMask = .FlexibleRightMargin | .FlexibleTopMargin | .FlexibleBottomMargin
        skipButton.addTarget(self, action: Selector("skipToNextStep"), forControlEvents: .TouchUpInside)
        buttonContainer.addSubview(skipButton)

        nextButton.frame = CGRect(
            x: skipButton.frame.maxX,
            y: 0,
            width: buttonContainer.frame.width - skipButton.frame.maxX,
            height: Size.buttonContainerHeight
        ).inset(all: inset)
        nextButton.autoresizingMask = .FlexibleWidth | .FlexibleTopMargin | .FlexibleBottomMargin
        nextButton.addTarget(self, action: Selector("proceedToNextStep"), forControlEvents: .TouchUpInside)
        buttonContainer.addSubview(nextButton)
    }

    func setupControllerContainer() {
        controllerContainer.frame = view.bounds.shrinkUp(buttonContainer.frame.height)
        controllerContainer.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        view.insertSubview(controllerContainer, belowSubview: buttonContainer)
    }

    func setupOnboardingControllers() {
        onboardingData = OnboardingData()

        let communityController = CommunitySelectionViewController()
        communityController.onboardingViewController = self
        communityController.currentUser = currentUser
        addOnboardingViewController(communityController)

        let awesomePeopleController = AwesomePeopleSelectionViewController()
        awesomePeopleController.onboardingViewController = self
        awesomePeopleController.currentUser = currentUser
        addOnboardingViewController(awesomePeopleController)

        let foundersController = FoundersSelectionViewController()
        foundersController.onboardingViewController = self
        foundersController.currentUser = currentUser
        addOnboardingViewController(foundersController)

        let importPromptController = ImportPromptViewController()
        importPromptController.onboardingViewController = self
        importPromptController.currentUser = currentUser
        addOnboardingViewController(importPromptController)

        let headerImageSelectionController = CoverImageSelectionViewController()
        headerImageSelectionController.onboardingViewController = self
        headerImageSelectionController.currentUser = currentUser
        addOnboardingViewController(headerImageSelectionController)

        let avatarImageSelectionController = AvatarImageSelectionViewController()
        avatarImageSelectionController.onboardingViewController = self
        avatarImageSelectionController.currentUser = currentUser
        addOnboardingViewController(avatarImageSelectionController)

        let profileInfoSelectionController = ProfileInfoViewController()
        profileInfoSelectionController.onboardingViewController = self
        profileInfoSelectionController.currentUser = currentUser
        addOnboardingViewController(profileInfoSelectionController)
    }

}

// MARK: Screen transitions
extension OnboardingViewController {

    private func showFirstViewController(viewController: UIViewController) {
        Tracker.sharedTracker.screenAppeared(viewController.title ?? viewController.readableClassName())

        if var onboardingStep = viewController as? OnboardingStep {
            onboardingStep.onboardingData = onboardingData
        }

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

}

// MARK: Moving through the screens
extension OnboardingViewController {

    public func goToNextStep(data: OnboardingData?) {
        self.visibleViewControllerIndex += 1

        if let nextViewController = onboardingViewControllers.safeValue(visibleViewControllerIndex) {
            goToController(nextViewController, data: data, direction: .Right)
        }
        else {
            done()
        }
    }

    public func goToPreviousStep() {
        self.visibleViewControllerIndex -= 1

        if self.visibleViewControllerIndex == -1 {
            self.visibleViewControllerIndex = 0
            return
        }

        if let prevViewController = onboardingViewControllers.safeValue(visibleViewControllerIndex)
        {
            goToController(prevViewController, data: onboardingData, direction: .Left)
        }
    }

    private func done() {
        parentAppController?.doneOnboarding()
    }

    public func goToController(viewController: UIViewController, data: OnboardingData?) {
        goToController(viewController, data: data, direction: .Right)
    }

}

// MARK: Controller transitions
extension OnboardingViewController {

    private func goToController(viewController: UIViewController, data: OnboardingData?, direction: OnboardingDirection) {
        if let visibleViewController = visibleViewController {
            canGoNext = false
            transitionFromViewController(visibleViewController, toViewController: viewController, direction: direction)
        }

        if viewController == onboardingViewControllers.last {
            nextButton.setTitle(NSLocalizedString("Done", comment: "Done button title"), forState: .Normal)
        }
        else {
            nextButton.setTitle(NSLocalizedString("Next", comment: "Next button title"), forState: .Normal)
        }

        if var onboardingStep = viewController as? OnboardingStep {
            onboardingData = data
            onboardingStep.onboardingData = data
            onboardingStep.onboardingStepBegin?()
        }
    }

    private func transitionFromViewController(visibleViewController: UIViewController, toViewController nextViewController: UIViewController, direction: OnboardingDirection) {
        if isTransitioning {
            return
        }

        Tracker.sharedTracker.screenAppeared(nextViewController.title ?? nextViewController.readableClassName())

        visibleViewController.willMoveToParentViewController(nil)
        addChildViewController(nextViewController)

        nextViewController.view.alpha = 1
        nextViewController.view.frame = CGRect(
                x: direction.rawValue * controllerContainer.frame.width,
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
                visibleViewController.view.frame.origin.x = -direction.rawValue * visibleViewController.view.frame.width
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
