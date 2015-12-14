//
//  UIViewController.swift
//  Ello
//
//  Created by Gordon Fontenot on 3/23/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

@objc protocol GestureNavigation {
    var backGestureEdges: UIRectEdge { get }
    func backGestureAction() -> Void
}

extension UIViewController: GestureNavigation {
    var backGestureEdges: UIRectEdge { return .Left }

    func backGestureAction() {
        if navigationController?.viewControllers.count > 1 {
            navigationController?.popViewControllerAnimated(true)
        }
    }

    public func findViewController(find: (UIViewController) -> Bool) -> UIViewController? {
        var controller: UIViewController?
        controller = self
        while controller != nil {
            if find(controller!) {
                return controller
            }
            controller = controller!.parentViewController
        }
        return nil
    }

}

extension UIViewController {

    func transition(
        from fromViewController: UIViewController,
        to toViewController: UIViewController,
        duration: NSTimeInterval = 0,
        options: UIViewAnimationOptions = [],
        animations: (() -> Void)? = nil, completion: ((Bool) -> Void)? = nil) -> Void
    {
        if AppSetup.sharedState.isTesting {
            animations?()
            transitionFromViewController(fromViewController,
                toViewController: toViewController,
                duration: duration,
                options: options,
                animations: nil,
                completion: nil)
            completion?(true)
        }
        else {
            transitionFromViewController(fromViewController,
                toViewController: toViewController,
                duration: duration,
                options: options,
                animations: animations,
                completion: completion)
        }
    }
}
