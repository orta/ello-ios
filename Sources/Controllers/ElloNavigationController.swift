//
//  ElloNavigationController.swift
//  Ello
//
//  Created by Sean on 1/19/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public let externalWebNotification = TypedNotification<String>(name: "externalWebNotification")

public class ElloNavigationController: UINavigationController, UIGestureRecognizerDelegate {

    var interactionController: UIPercentDrivenInteractiveTransition?
    var postChangedNotification:NotificationObserver?
    var relationshipChangedNotification:NotificationObserver?
    var rootViewControllerName : String?
    public var currentUser : User? {
        didSet { didSetCurrentUser() }
    }

    var backGesture: UIScreenEdgePanGestureRecognizer?

    override public var tabBarItem: UITabBarItem? {
        get { return childViewControllers.first?.tabBarItem ?? super.tabBarItem }
        set { self.tabBarItem = newValue }
    }

    enum RootViewControllers: String {
        case Notifications = "NotificationsViewController"
        case Profile = "ProfileViewController"
        case Omnibar = "OmnibarViewController"
        case Discover = "DiscoverViewController"

        func controllerInstance(user: User) -> BaseElloViewController {
            switch self {
            case Notifications: return NotificationsViewController()
            case Profile: return ProfileViewController(user: user)
            case Omnibar: return OmnibarViewController()
            case Discover: return DiscoverViewController()
            }
        }
    }

    public func setProfileData(currentUser: User) {
        postNotification(SettingChangedNotification, currentUser)
        self.currentUser = currentUser
        if self.viewControllers.count == 0 {
            if let rootViewControllerName = rootViewControllerName {
                if let controller = RootViewControllers(rawValue:rootViewControllerName)?.controllerInstance(currentUser) {
                    controller.currentUser = currentUser
                    self.viewControllers = [controller]
                }
            }
        }
    }

    func didSetCurrentUser() {
        if self.viewControllers.count > 0 {
            var controllers = self.viewControllers as! [ControllerThatMightHaveTheCurrentUser]
            for controller in controllers {
                controller.currentUser = currentUser
            }
        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationBarHidden(true, animated: false)

        transitioningDelegate = self
        delegate = self

        backGesture = UIScreenEdgePanGestureRecognizer(target: self, action: Selector("handleBackGesture:"))
        backGesture.map(self.view.addGestureRecognizer)

        postChangedNotification = NotificationObserver(notification: PostChangedNotification) { (post, change) in
            switch change {
            case .Delete:
                var keepers = [AnyObject]()
                for controller in self.childViewControllers {
                    if let postDetailVC = controller as? PostDetailViewController {
                        if let postId = postDetailVC.post?.id where postId != post.id {
                            keepers.append(controller)
                        }
                    }
                    else {
                        keepers.append(controller)
                    }
                }
                self.setViewControllers(keepers, animated: true)
            default: _ = "noop"
            }
        }

        relationshipChangedNotification = NotificationObserver(notification: RelationshipChangedNotification) { user in
            switch user.relationshipPriority {
            case .Block:
                var keepers = [AnyObject]()
                for controller in self.childViewControllers {
                    if let userStreamVC = controller as? ProfileViewController {
                        if let userId = userStreamVC.user?.id where userId != user.id {
                            keepers.append(controller)
                        }
                    }
                    else {
                        keepers.append(controller)
                    }
                }
                self.setViewControllers(keepers, animated: true)
            default:
                _ = "noop"
            }
        }
    }

    func handleBackGesture(gesture: UIScreenEdgePanGestureRecognizer) {
        let percentThroughView = gesture.percentageThroughView(gesture.edges)

        switch gesture.state {
        case .Began:
            interactionController = UIPercentDrivenInteractiveTransition()
            topViewController.backGestureAction()
        case .Changed:
            interactionController?.updateInteractiveTransition(percentThroughView)
        case .Ended, .Cancelled:
            if percentThroughView > 0.5 {
                interactionController?.finishInteractiveTransition()
            } else {
                interactionController?.cancelInteractiveTransition()
            }
            interactionController = nil
        default:
            interactionController = nil
        }
    }

}

extension ElloNavigationController: UIGestureRecognizerDelegate {

    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

}

extension ElloNavigationController: UIViewControllerTransitioningDelegate {

    public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ForwardAnimator()
    }

    public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return BackAnimator()
    }

    public func interactionControllerForPresentation(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }

    public func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }

}

extension ElloNavigationController: UINavigationControllerDelegate {


    public func navigationController(navigationController: UINavigationController, didShowViewController viewController: UIViewController, animated: Bool) {
        backGesture?.edges = viewController.backGestureEdges
        
        if !viewController.isKindOfClass(ProfileViewController) {
            Tracker.sharedTracker.screenAppeared(viewController.title ?? viewController.readableClassName())
        }
        
    }

    public func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        switch (toVC, fromVC) {
        case (is DrawerViewController, is StreamContainerViewController): return drawerAnimatorForOperation(operation)
        case (is StreamContainerViewController, is DrawerViewController): return drawerAnimatorForOperation(operation)
        default: return defaultAnimatorForOperation(operation)
        }
    }

    public func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }

    func defaultAnimatorForOperation(operation: UINavigationControllerOperation) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .Push: return ForwardAnimator()
        case .Pop: return BackAnimator()
        default: return .None
        }
    }

    func drawerAnimatorForOperation(operation: UINavigationControllerOperation) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .Push: return BackAnimator()
        case .Pop: return ForwardAnimator()
        default: return .None
        }
    }
}
