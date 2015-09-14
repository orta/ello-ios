//
//  SimpleStreamViewControllerSpec.swift
//  Ello
//
//  Created by Ryan Boyajian on 3/5/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Ello
import Foundation
import Quick
import Nimble


class SimpleStreamViewControllerSpec: QuickSpec {
    override func spec() {

        let subject = SimpleStreamViewController(endpoint: ElloAPI.UserStreamFollowers(userId: "666"), title: "Followers")

        describe("initialization") {

            it("can be instantiated") {
                expect(subject).notTo(beNil())
            }

            it("is a BaseElloViewController") {
                expect(subject).to(beAKindOf(BaseElloViewController.self))
            }

            it("is a StreamableViewController") {
                expect(subject).to(beAKindOf(StreamableViewController.self))
            }

            it("is a SimpleStreamViewController") {
                expect(subject).to(beAKindOf(SimpleStreamViewController.self))
            }

            it("sets the title") {
                expect(subject.title) == "Followers"
            }
        }
    }
}
