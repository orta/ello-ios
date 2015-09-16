//
//  Animators.swift
//  Ello
//
//  Created by Gordon Fontenot on 3/18/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

let DefaultAnimationDuration: NSTimeInterval = 0.25

public class ForwardAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return DefaultAnimationDuration
    }

    public func animateTransition(context: UIViewControllerContextTransitioning) {
        let toView = (context.viewControllerForKey(UITransitionContextToViewControllerKey)?.view)!
        let fromView = (context.viewControllerForKey(UITransitionContextFromViewControllerKey)?.view)!

        let from = fromView.frame
        toView.frame.origin.x = toView.frame.size.width
        if let containerView = context.containerView() {
            containerView.addSubview(toView)
        }

        UIView.animateWithDuration(transitionDuration(context),
            delay: 0.0,
            options: .CurveEaseIn,
            animations: {
                toView.frame = from
                fromView.frame.origin.x -= fromView.frame.size.width
            },
            completion: { _ in
                context.completeTransition(!context.transitionWasCancelled())
        })
    }
}

public class BackAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return DefaultAnimationDuration
    }

    public func animateTransition(context: UIViewControllerContextTransitioning) {
        let toView = (context.viewControllerForKey(UITransitionContextToViewControllerKey)?.view)!
        let fromView = (context.viewControllerForKey(UITransitionContextFromViewControllerKey)?.view)!

        let from = fromView.frame
        toView.frame.origin.x = -toView.frame.size.width
        if let containerView = context.containerView() {
            containerView.addSubview(toView)
        }

        UIView.animateWithDuration(transitionDuration(context),
            delay: 0.0,
            options: .CurveEaseIn,
            animations: {
                toView.frame = from
                fromView.frame.origin.x += fromView.frame.size.width
            },
            completion: { _ in
                context.completeTransition(!context.transitionWasCancelled())
        })
    }
}
