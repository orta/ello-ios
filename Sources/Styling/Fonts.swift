//
//  Fonts.swift
//  Ello
//
//  Created by Sean Dougherty on 11/24/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit

extension UIFont {
    // HEADING (Profile Header) uses Atlas Grotesk
    public class func regularFont(size:CGFloat) -> UIFont { return UIFont(name: "AtlasGrotesk-Regular", size: size)! }
    public class func regularBoldFont(size:CGFloat) -> UIFont { return UIFont(name: "AtlasGrotesk-Bold", size: size)! }
    public class func typewriterFont(size:CGFloat) -> UIFont { return UIFont(name: "AtlasTypewriter-Regular", size: size)! }
}
