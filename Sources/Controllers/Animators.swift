//
//  Animators.swift
//  Ello
//
//  Created by Gordon Fontenot on 3/18/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

private let defaultDuration: NSTimeInterval = 0.25

class ForwardAnimator : NSObject, UIViewControllerAnimatedTransitioning {

    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return defaultDuration
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
        return defaultDuration
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
