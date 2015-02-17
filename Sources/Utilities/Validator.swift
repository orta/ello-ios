//
//  Validator.swift
//  Ello
//
//  Created by Sean Dougherty on 11/25/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit

public extension String {

    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,20}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest?.evaluateWithObject(self)
        return result ?? false
    }

    func isValidPassword() -> Bool {
        return countElements(self) >= 8
    }

}
