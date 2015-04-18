//
//  ScreenExtensions.swift
//  Ello
//
//  Created by Sean Dougherty on 12/9/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit


extension UIScreen {

    class func screenWidth() -> CGFloat {
        return UIScreen.mainScreen().bounds.size.width
    }

    class func screenHeight() -> CGFloat {
        return UIScreen.mainScreen().bounds.size.height
    }

    class func screenSize() -> CGSize {
        return UIScreen.mainScreen().bounds.size
    }

    class func screenBounds() -> CGRect {
        return UIScreen.mainScreen().bounds
    }

    class func scale() -> CGFloat {
        return UIScreen.mainScreen().scale
    }

}