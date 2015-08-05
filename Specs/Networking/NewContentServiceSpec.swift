//
//  NewContentServiceSpec.swift
//  Ello
//
//  Created by Sean on 7/31/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble
import Moya
import SwiftyUserDefaults

class NewContentServiceSpec: QuickSpec {
    override func spec() {
        describe("NewContentService") {

            var subject = NewContentService()

            beforeEach {
                subject = NewContentService()
            }

            describe("updateCreatedAt(_:)") {

                beforeEach {

                }

                context("no existing date stored") {

                }

                context("older existing date stored") {

                }

                context("newer existing date stored") {

                }
            }
        }
    }
}