//
//  AppSetup.swift
//  Ello
//
//  Created by Sean Dougherty on 11/21/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit

class AppSetup {

    lazy var useStaging = true
    var isTesting = false

    class var sharedState : AppSetup {
        struct Static {
            static let instance = AppSetup()
        }
        return Static.instance
    }

    init() {
        let defaults = NSUserDefaults.standardUserDefaults()
        useStaging = defaults.boolForKey("ElloUseStaging")

        if let inTests: AnyClass = NSClassFromString("XCTest") { isTesting = true }
    }
}
