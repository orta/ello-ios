//
//  ElloNavigationController.swift
//  Ello
//
//  Created by Sean on 1/19/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//
let externalWebNotification = Notification<String>(name: "externalWebNotification")

class ElloNavigationController: UINavigationController, UIGestureRecognizerDelegate {

    var interactionController: UIPercentDrivenInteractiveTransition?
    var externalWebObserver: NotificationObserver?
    let externalWebController: UINavigationController = KINWebBrowserViewController.navigationControllerWithWebBrowser()
    var rootViewControllerName : String?
    var currentUser : User? {
        didSet { assignCurrentUser() }
    }

    enum ViewControllers: String {
        case Notifications = "NotificationsViewController"
        case Profile = "ProfileViewController"

        func controllerInstance(user : User) -> BaseElloViewController {
            switch self {
            case Notifications: return NotificationsViewController()
            case Profile: return ProfileViewController(user: user)
            }
        }
    }

    func assignCurrentUser() {
        if self.viewControllers.count == 0 {
            if let rootViewControllerName = rootViewControllerName {
                if let controller = ViewControllers(rawValue:rootViewControllerName)?.controllerInstance(currentUser!) {
                    controller.currentUser = self.currentUser
                    self.viewControllers = [controller]
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        transitioningDelegate = self
        delegate = self

        let left = UIScreenEdgePanGestureRecognizer(target: self, action: "handleSwipeFromLeft:")
        left.edges = .Left
        self.view.addGestureRecognizer(left);

        externalWebObserver = NotificationObserver(notification: externalWebNotification) { url in
            self.showExternalWebView(url)
        }
    }

    func showExternalWebView(url: String) {
        presentViewController(externalWebController, animated: true, completion: nil)
        if let externalWebView = externalWebController.rootWebBrowser() {
            externalWebView.loadURLString(url)
        }
    }

    func handleSwipeFromLeft(gesture: UIScreenEdgePanGestureRecognizer) {
        let percent = gesture.translationInView(gesture.view!).x / gesture.view!.bounds.size.width

        switch gesture.state {
        case .Began:
            interactionController = UIPercentDrivenInteractiveTransition()
            if viewControllers.count > 1 {
                popViewControllerAnimated(true)
            }
        case .Changed:
            interactionController?.updateInteractiveTransition(percent)
        case .Ended, .Cancelled:
            if percent > 0.5 {
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

    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

}

extension ElloNavigationController: UIViewControllerTransitioningDelegate {

    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ForwardAnimator()
    }

    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return BackAnimator()
    }

    func interactionControllerForPresentation(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }

    func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }

}

extension ElloNavigationController: UINavigationControllerDelegate {

    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        if operation == .Push {
            return ForwardAnimator()
        } else if operation == .Pop {
            return BackAnimator()
        }
        return nil
    }

    func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }

}

class ForwardAnimator : NSObject, UIViewControllerAnimatedTransitioning {

    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 0.25
    }

    func animateTransition(context: UIViewControllerContextTransitioning) {
        let toView = context.viewControllerForKey(UITransitionContextToViewControllerKey)?.view
        let fromView = context.viewControllerForKey(UITransitionContextFromViewControllerKey)?.view

        if let toView = toView {
            if let fromView = fromView {
                let from = fromView.frame
                let to = toView.frame
                toView.frame = CGRect(x: from.origin.x + from.size.width, y: from.origin.y, width: to.size.width, height: to.size.height)
                context.containerView().addSubview(toView)

                UIView.animateWithDuration(transitionDuration(context),
                    delay: 0.0,
                    options: UIViewAnimationOptions.CurveEaseIn,
                    animations: {
                        toView.frame = from
                        fromView.frame = CGRect(x: from.origin.x - from.size.width, y: from.origin.y, width: from.size.width, height: from.size.height)
                    },
                    completion: { finished in
                        context.completeTransition(!context.transitionWasCancelled())
                    })
            }
        }
    }
}

class BackAnimator : NSObject, UIViewControllerAnimatedTransitioning {

    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 0.25
    }

    func animateTransition(context: UIViewControllerContextTransitioning) {
        let toView = context.viewControllerForKey(UITransitionContextToViewControllerKey)?.view
        let fromView = context.viewControllerForKey(UITransitionContextFromViewControllerKey)?.view

        context.containerView().insertSubview(toView!, belowSubview: fromView!)

        if let toView = toView {
            if let fromView = fromView {
                let from = fromView.frame
                let to = toView.frame
                toView.frame = CGRect(x: from.origin.x - from.size.width, y: from.origin.y, width: to.size.width, height: to.size.height)
                context.containerView().addSubview(toView)

                UIView.animateWithDuration(transitionDuration(context),
                    delay: 0.0,
                    options: UIViewAnimationOptions.CurveEaseIn,
                    animations: {
                        toView.frame = from
                        fromView.frame = CGRect(x: from.origin.x + from.size.width, y: from.origin.y, width: from.size.width, height: from.size.height)
                    }, completion: { finished in
                        context.completeTransition(!context.transitionWasCancelled())
                    })
            }
        }
    }
}

