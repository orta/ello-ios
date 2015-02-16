//
//  NumberExtensions.swift
//  Ello
//
//  Created by Sean Dougherty on 12/10/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Foundation

extension Int {

    func localizedStringFromNumber() -> NSString {
        if self == 0 {
            return ""
        }
        return NSNumberFormatter.localizedStringFromNumber(NSNumber(integer:self), numberStyle: NSNumberFormatterStyle.DecimalStyle)
    }

}