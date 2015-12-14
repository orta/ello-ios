//
//  ScreenExtensions.swift
//  Ello
//
//  Created by Sean Dougherty on 12/9/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

extension UIWindow {
    class var mainWindow: UIWindow {
        return UIApplication.sharedApplication().keyWindow ?? UIWindow()
    }

    class func windowBounds() -> CGRect {
        return mainWindow.bounds
    }

    class func windowSize() -> CGSize {
        return windowBounds().size
    }

    class func windowWidth() -> CGFloat {
        return windowSize().width
    }

    class func windowHeight() -> CGFloat {
        return windowSize().height
    }

}
