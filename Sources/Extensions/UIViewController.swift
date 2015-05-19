//
//  UIViewController.swift
//  Ello
//
//  Created by Gordon Fontenot on 3/23/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit

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
