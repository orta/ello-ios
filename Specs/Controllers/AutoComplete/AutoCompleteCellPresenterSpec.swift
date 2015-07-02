//
//  AutoCompleteCellPresenterSpec.swift
//  Ello
//
//  Created by Sean on 6/29/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble

class AutoCompleteCellPresenterSpec: QuickSpec {
    override func spec() {
        describe("configure") {
            beforeEach {
                supressRequestsTo("www.example.com")
            }
        }
    }
}
