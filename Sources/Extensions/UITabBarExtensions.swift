//
//  UITabBarExtensions.swift
//  Ello
//
//  Created by Colin Gray on 5/26/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

extension UITabBar {

    var itemViews: [UIView] {
        return subviews.filter { $0 is UIControl } as! [UIView]
    }

    func itemPositionsIn(view: UIView) -> [CGRect] {
        return itemViews.map { self.convertRect($0.frame, toView: view) }
    }

}
