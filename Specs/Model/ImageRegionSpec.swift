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
                expect(actual["kind"] as? String).to(equal(expected["kind"] as? String))

                let actualData = actual["data"] as [String : AnyObject]
                let expectedData = expected["data"] as [String : AnyObject]

                expect(actualData["alt"] as? String).to(equal(expectedData["alt"] as? String))
                expect(actualData["via"] as? String).to(equal(expectedData["via"] as? String))
                expect(actualData["url"] as? String).to(equal(url.absoluteString))
            }
            it("returns json even if there's no url") {
                let region = ImageRegion(asset: nil, alt: nil, url: nil)
                let actual = region.toJSON()
                let expected : [String : AnyObject] = [
                    "kind": "image",
                    "data": [String:String]()
                ]
                expect(actual["kind"] as? String).to(equal(expected["kind"] as? String))
                expect(actual["data"] as? [String : String]).to(equal(expected["data"] as? [String : String]))
            }
        }
    }
}