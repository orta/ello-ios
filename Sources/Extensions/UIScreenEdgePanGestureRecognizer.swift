//
//  UIScreenEdgePanGestureRecognizer.swift
//  Ello
//
//  Created by Gordon Fontenot on 3/23/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit

extension UIScreenEdgePanGestureRecognizer {
    func percentageThroughView(backEdge: UIRectEdge) -> CGFloat {
        let view = self.view!
        let x = locationInView(view).x
        let width = view.bounds.size.width
        let percent = x / width

        if (translationInView(view).x > 0.0) && (backEdge == UIRectEdge.Left) {
            return percent
        }

        if (translationInView(view).x < 0.0) && (backEdge == UIRectEdge.Right) {
            return 1.0 - percent
        }

        return 0.0
    }
}