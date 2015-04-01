//
//  StreamableViewController.swift
//  Ello
//
//  Created by Ryan Boyajian on 4/1/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Quick
import Nimble
import SSPullToRefresh


class StreamableViewControllerSpec: QuickSpec {
    override func spec() {

        var controller = StreamableViewController()

        describe("initialization") {

            it("can be instantiated from storyboard") {
                expect(controller).notTo(beNil())
            }

            it("is a BaseElloViewController") {
                expect(controller).to(beAKindOf(BaseElloViewController.self))
            }


            it("is a StreamableViewController") {
                expect(controller).to(beAKindOf(StreamableViewController.self))
            }
        }
    }
}
