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
    public class func regularBoldFont(size:CGFloat) -> UIFont { return UIFont(name: "AtlasGrotesk-Bold", size: size)! }
    public class func typewriterFont(size:CGFloat) -> UIFont { return UIFont(name: "AtlasTypewriter-Regular", size: size)! }

    public class func printAvailableFonts() {
        for familyName:AnyObject in UIFont.familyNames()
        {
            println("Family Name: \(familyName)")
            for fontName:AnyObject in UIFont.fontNamesForFamilyName(familyName as! String)
            {
                println("--Font Name: \(fontName)")
            }
        }
    }
}
