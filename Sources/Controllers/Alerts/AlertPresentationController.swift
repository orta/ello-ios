//
//  AlertPresentationController.swift
//  Ello
//
//  Created by Gordon Fontenot on 4/2/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

class AlertPresentationController: UIPresentationController {
    let background: UIView = {
        let background = UIView(frame: CGRectZero)
        background.backgroundColor = UIColor.modalBackground()
        return background
    }()
}

// MARK: View Lifecycle
extension AlertPresentationController {
    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        let alertViewController = presentedViewController as! AlertViewController
        alertViewController.resize()

        let gesture = UITapGestureRecognizer(target:self, action: Selector("dismiss"))
        background.addGestureRecognizer(gesture)
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

extension AlertPresentationController {
    func dismiss() {
        let alertViewController = presentedViewController as! AlertViewController
        if alertViewController.dismissable {
            presentedViewController.dismissViewControllerAnimated(true, completion: .None)
        }
    }
}
