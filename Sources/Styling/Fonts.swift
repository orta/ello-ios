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
    public class func typewriterBoldFont(size:CGFloat) -> UIFont { return UIFont(name: "AtlasTypewriter-Medium", size: size)! }
    public class func typewriterItalicFont(size:CGFloat) -> UIFont { return UIFont(name: "AtlasTypewriter-RegularItalic", size: size)! }
    public class func typewriterBoldItalicFont(size:CGFloat) -> UIFont { return UIFont(name: "AtlasTypewriter-MediumItalic", size: size)! }

    public class func typewriterEditorFont(size:CGFloat) -> UIFont { return UIFont(name: "AtlasTypewriter-Regular", size: size)! }
    public class func typewriterEditorItalicFont(size:CGFloat) -> UIFont { return UIFont(name: "AtlasTypewriter-RegularItalic", size: size)! }
    public class func typewriterEditorBoldFont(size:CGFloat) -> UIFont { return UIFont(name: "AtlasTypewriter-Bold", size: size)! }
    public class func typewriterEditorBoldItalicFont(size:CGFloat) -> UIFont { return UIFont(name: "AtlasTypewriter-BoldItalic", size: size)! }

    public class func printAvailableFonts() {
        for familyName:AnyObject in UIFont.familyNames()
        {
            print("Family Name: \(familyName)")
            for fontName:AnyObject in UIFont.fontNamesForFamilyName(familyName as! String)
            {
                print("--Font Name: \(fontName)")
            }
        }
    }
}
