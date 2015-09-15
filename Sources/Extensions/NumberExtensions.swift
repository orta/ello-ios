//
//  NumberExtensions.swift
//  Ello
//
//  Created by Sean Dougherty on 12/10/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Foundation

let billion = 1_000_000_000.0
let million = 1_000_000.0
let thousand = 1_000.0

public extension Int {

    func numberToHuman(showZero showZero: Bool = false) -> String {
        if self == 0 && !showZero { return "" }

        let double = Double(self)
        let num: Float
        let suffix: String
        if double >= billion {
            num = Float(round(double / billion * 100.0) / 100.0)
            suffix = "B"
        }
        else if double >= million {
            num = Float(round(double / million * 100.0) / 100.0)
            suffix = "M"
        }
        else if double >= thousand {
            num = Float(round(double / thousand * 100.0) / 100.0)
            suffix = "K"
        }
        else {
            num = Float(round(double * 100.0) / 100.0)
            suffix = ""
        }
        var strNum = "\(num)"
        let strArr = strNum.characters.split { $0 == "." }.map { String($0) }
        if strArr.last == "0" {
            strNum = strArr.first!
        }
        return "\(strNum)\(suffix)"
    }

    func localizedStringFromNumber() -> String {
        if self == 0 {
            return ""
        }
        return NSNumberFormatter.localizedStringFromNumber(NSNumber(integer:self), numberStyle: NSNumberFormatterStyle.DecimalStyle)
    }

}
