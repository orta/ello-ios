//
//  ImageRegionSpec.swift
//  Ello
//
//  Created by Colin Gray on 3/6/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Quick
import Nimble


class ImageRegionSpec: QuickSpec {
    override func spec() {
        describe("-toJSON") {
            it("returns json") {
                let url = NSURL(string: "http://ello.co")!
                let region = ImageRegion(asset: nil, alt: "image.png", url: url)
                let actual : [String : AnyObject] = region.toJSON()
                let expected : [String : AnyObject] = [
                    "kind": "image",
                    "data": [
                        "alt": "image.png",
                        "via": "direct",
                        "url": url
                    ]
                ]
                expect(actual).to(equal(expected))
            }
            it("returns json even if there's no url") {
                let region = ImageRegion(asset: nil, alt: nil, url: nil)
                let actual = region.toJSON()
                let expected : [String : AnyObject] = [
                    "kind": "image",
                    "data": [:]
                ]
                expect(actual).to(equal(expected))
            }
        }
    }
}