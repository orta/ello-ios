//
//  Colors.swift
//  Ello
//
//  Created by Sean Dougherty on 11/21/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit

extension UIColor {
    // TODO: memoize these return values at some point
    // These colors are taken from the web styleguide. Any other variations should be
    // double checked with B&F or normalized to one of these..
    // black - 0x000000
    class func grey231F20() -> UIColor { return UIColor(hex: 0x231F20) } // HEADING (Profile Header) uses Atlas Grotesk
    class func grey3() -> UIColor { return UIColor(hex: 0x333333) }
    class func grey4D() -> UIColor { return UIColor(hex: 0x4D4D4D) }
    class func grey6() -> UIColor { return UIColor(hex: 0x666666) }
    class func greyA() -> UIColor { return UIColor(hex: 0xAAAAAA) }
    class func greyE5() -> UIColor { return UIColor(hex: 0xE5E5E5) }
    class func greyF1() -> UIColor { return UIColor(hex: 0xF1F1F1) }
    // white - 0xFFFFFF
    class func yellowFFFFCC() -> UIColor { return UIColor(hex: 0xFFFFCC) } // Used to color @ mention in omnibar/posts
    class func redFFCCCC() -> UIColor { return UIColor(hex: 0xFFCCCC) } // Used to color @@ direct mention in omnibar/posts (not implemented yet)
    // red - 0xFF0000
}
