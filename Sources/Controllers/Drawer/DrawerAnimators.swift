//
//  DrawerAnimators.swift
//  Ello
//
//  Created by Colin Gray on 2/11/16.
//  Copyright © 2016 Ello. All rights reserved.
//

public typealias Animator = (animations: () -> Void, completion: (Bool) -> Void) -> Void

public class DrawerAnimator: NSObject, UIViewControllerTransitioningDelegate  {
    let popControl = DrawerPopControl()

    public func animationControllerForPresentedController(
        presented: UIViewController, presentingController presenting: UIViewController,
        sourceController source: UIViewController
        ) -> UIViewControllerAnimatedTransitioning? {
            popControl.presentingController = presenting
            return DrawerPushAnimator(popControl: popControl)
    }

    public func animationControllerForDismissedController(
        dismissed: UIViewController
        ) -> UIViewControllerAnimatedTransitioning? {
            return DrawerPopAnimator(popControl: popControl)
    }

}

public class DrawerPushAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let popControl: DrawerPopControl

    init(popControl: DrawerPopControl) {
        self.popControl = popControl
        super.init()
    }

    public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return DefaultAnimationDuration
    }

    public func animateTransition(context: UIViewControllerContextTransitioning) {
        let streamController = context.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let drawerView = context.viewForKey(UITransitionContextToViewKey)!
        let streamView = streamController.view
        let containerView = context.containerView() ?? UIView()
        let animator: Animator = { animations, completion in
            UIView.animateWithDuration(self.transitionDuration(context),
                delay: 0.0,
                options: .CurveEaseIn,
                animations: animations,
                completion: completion
                )
        }

        animateTransition(
            streamView: streamView, drawerView: drawerView, containerView: containerView,
            animator: animator
        ) {
            context.completeTransition(!context.transitionWasCancelled())
        }
    }

    func animateTransition(
        streamView streamView: UIView, drawerView: UIView, containerView: UIView,
        animator: Animator, completion: () -> Void
    ) {
        popControl.frame = streamView.bounds

        drawerView.frame = streamView.frame
        containerView.addSubview(drawerView)
        streamView.addSubview(popControl)
        drawerView.addSubview(streamView)

        animator(animations: {
            let deltaX = streamView.frame.size.width - 150
            streamView.frame.origin.x += deltaX
        }, completion: { _ in
            completion()
        })
    }
}

public class DrawerPopAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let popControl: DrawerPopControl

    init(popControl: DrawerPopControl) {
        self.popControl = popControl
        super.init()
    }

    public func transitionDuration(context: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        if let drawerController = context?.viewControllerForKey(UITransitionContextFromViewControllerKey) as? DrawerViewController {
            if drawerController.isLoggingOut {
                return 0
            }
        }
        return DefaultAnimationDuration
    }

    public func animateTransition(context: UIViewControllerContextTransitioning) {
        let streamController = context.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let streamView = streamController.view
        let drawerView = context.viewForKey(UITransitionContextFromViewKey)!
        let containerView = context.containerView() ?? UIView()
        let animator: Animator = { animations, completion in
            UIView.animateWithDuration(self.transitionDuration(context),
                delay: 0.0,
                options: .CurveEaseIn,
                animations: animations,
                completion: completion
                )
        }

        animateTransition(
            streamView: streamView, drawerView: drawerView, containerView: containerView,
            animator: animator
        ) {
            context.completeTransition(!context.transitionWasCancelled())
        }
    }

    func animateTransition(
        streamView streamView: UIView, drawerView: UIView, containerView: UIView,
        animator: Animator, completed: () -> Void
    ) {
        containerView.insertSubview(drawerView, atIndex: 0)

        animator(animations: {
            self.popControl.frame.origin.x = 0
            streamView.frame.origin.x = 0
        }, completion: { _ in
            self.popControl.removeFromSuperview()
            drawerView.removeFromSuperview()
            completed()

            if let windowOpt = UIApplication.sharedApplication().delegate?.window,
                window = windowOpt,
                rootViewController = window.rootViewController
            {
                window.addSubview(rootViewController.view)
            }
        })
    }
}
