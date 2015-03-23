//
//  UINavigationItem.swift
//  Ello
//
//  Created by Colin Gray on 3/20/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

extension UINavigationItem {

    func fixNavBarItemPadding() {
        let negativeSpacer = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
        negativeSpacer.width = -22
        if let rightBarButtonItems = self.rightBarButtonItems {
            self.rightBarButtonItems = [negativeSpacer] + rightBarButtonItems
        }

        if let leftBarButtonItems = self.leftBarButtonItems {
            self.leftBarButtonItems = [negativeSpacer] + leftBarButtonItems
        }
    }

}
