//
//  StringExtensions.swift
//  Ello
//
//  Created by Sean Dougherty on 12/15/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Foundation

extension String {

    func stripHTML() -> String {
        return self.stringByReplacingOccurrencesOfString("<[^>]+>", withString: "", options: NSStringCompareOptions.RegularExpressionSearch, range: nil)
    }
}