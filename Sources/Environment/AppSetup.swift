//
//  AppSetup.swift
//  Ello
//
//  Created by Sean Dougherty on 11/21/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

public class AppSetup {
    public struct Size {
        public static let calculatorHeight = CGFloat(20)
    }

    public var isTesting = false
    private var _isSimulator: Bool?
    public var isSimulator: Bool! {
        get { return _isSimulator ?? (UIDevice.currentDevice().model != "iPhone Simulator") }
        set { _isSimulator = newValue }
    }

    public class var sharedState : AppSetup {
        struct Static {
            static let instance = AppSetup()
        }
        return Static.instance
    }

    public init() {
        if let inTests: AnyClass = NSClassFromString("XCTest") {
            isTesting = true
        }
    }

}
