//
//  AlertPresentationController.swift
//  Ello
//
//  Created by Gordon Fontenot on 4/2/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

class AlertPresentationController: UIPresentationController {
    let background: UIView

    override init(presentedViewController: UIViewController!, presentingViewController: UIViewController!) {
        background = UIView(frame: CGRectZero)
        background.backgroundColor = UIColor.modalBackground()
        super.init(presentedViewController: presentedViewController, presentingViewController: presentingViewController)
    }
}

// MARK: View Lifecycle
extension AlertPresentationController {
    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        let alertView = presentedViewController as! AlertViewController
        alertView.view.frame.size = alertView.desiredSize
        alertView.view.center = containerView.center
    }
}

// MARK: Presentation
extension AlertPresentationController {
    override func presentationTransitionWillBegin() {
        background.alpha = 0
        background.frame = containerView.bounds
        containerView.addSubview(background)

        let transitionCoordinator = presentingViewController.transitionCoordinator()
        transitionCoordinator?.animateAlongsideTransition({ _ in
            self.background.alpha = 1
        }, completion: .None)

        containerView.addSubview(presentedView())
    }

    override func dismissalTransitionWillBegin() {
        let transitionCoordinator = presentingViewController.transitionCoordinator()
        transitionCoordinator?.animateAlongsideTransition({ _ in
            self.background.alpha = 0
        }, completion: .None)
    }

    override func dismissalTransitionDidEnd(completed: Bool) {
        if completed {
            background.removeFromSuperview()
        }
    }
}
