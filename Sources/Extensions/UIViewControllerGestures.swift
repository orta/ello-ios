//
//  UIViewControllerGestures.swift
//  Ello
//
//  Created by Gordon Fontenot on 3/23/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit

@objc protocol GestureNavigation {
    var backGestureEdges: UIRectEdge { get }
    func backGestureAction() -> ()
}

extension UIViewController: GestureNavigation {
    var backGestureEdges: UIRectEdge { return .Left }

    func backGestureAction() {
        if navigationController?.viewControllers.count > 1 {
            navigationController?.popViewControllerAnimated(true)
        }
    }
}
