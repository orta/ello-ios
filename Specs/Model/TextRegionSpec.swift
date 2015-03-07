//
//  TextRegionSpec.swift
//  Ello
//
//  Created by Colin Gray on 3/6/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Quick
import Nimble


class TextRegionSpec: QuickSpec {
    override func spec() {
        describe("-toJSON") {
            it("returns json") {
                let url = NSURL(string: "http://ello.co")!
                let region = TextRegion(content: "content")
                let actual = region.toJSON() as [String : String]
                let expected : [String : String] = [
                    "kind": "text",
                    "data": "content",
                ]
                expect(actual["data"]).to(equal(expected["data"]))
            }
        }
    }
}