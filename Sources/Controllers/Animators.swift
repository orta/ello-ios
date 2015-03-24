//
//  Animators.swift
//  Ello
//
//  Created by Gordon Fontenot on 3/18/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

private let defaultDuration: NSTimeInterval = 0.25

class ForwardAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return defaultDuration
    }

    func animateTransition(context: UIViewControllerContextTransitioning) {
        let toView = (context.viewControllerForKey(UITransitionContextToViewControllerKey)?.view)!
        let fromView = (context.viewControllerForKey(UITransitionContextFromViewControllerKey)?.view)!

        let from = fromView.frame
        let to = toView.frame
        toView.frame.origin.x += toView.frame.size.width
        context.containerView().addSubview(toView)

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

class BackAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return defaultDuration
    }

    func animateTransition(context: UIViewControllerContextTransitioning) {
        let toView = (context.viewControllerForKey(UITransitionContextToViewControllerKey)?.view)!
        let fromView = (context.viewControllerForKey(UITransitionContextFromViewControllerKey)?.view)!

        let from = fromView.frame
        let to = toView.frame
        toView.frame.origin.x -= toView.frame.size.width
        context.containerView().addSubview(toView)

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
