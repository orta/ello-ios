//
//  ServerDateFormatterSpec.swift
//  Ello
//
//  Created by Sean on 7/27/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble

// GROSS, thanks Apple for making it hard to change Locale for testing purposes
extension NSLocale {
    public class func defaultToArab() {
        method_exchangeImplementations(class_getClassMethod(self, Selector("currentLocale")), class_getClassMethod(self, Selector("ello_currentLocale")))
    }

    public class func defaultToNormal() {
        method_exchangeImplementations(class_getClassMethod(self, Selector("ello_currentLocale")), class_getClassMethod(self, Selector("currentLocale")))
    }

    // MARK: - Method Swizzling

    class func ello_currentLocale() -> NSLocale {
        return NSLocale(localeIdentifier: "uz_Arab")
    }
}


class ServerDateFormatterSpec: QuickSpec {
    override func spec() {
        describe("ServerDateFormatter") {

            context("arabic locale") {
                it("outputs the correct string") {
                    NSLocale.defaultToArab()
                    let sep_30_1978 = NSDate(timeIntervalSince1970: 275961600)

                    expect(sep_30_1978.toNSString()) == "1978-09-30T00:00:00.000Z"

                    NSLocale.defaultToNormal()
                }
            }

            context("non arabic locale") {
                it("outputs the correct string") {
                    let sep_30_1978 = NSDate(timeIntervalSince1970: 275961600)

                    expect(sep_30_1978.toNSString()) == "1978-09-30T00:00:00.000Z"
                }
            }

        }
    }
}
