//
//  NSURLSpec.swift
//  Ello
//
//  Created by Gordon Fontenot on 5/20/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble

class NSURLSpec: QuickSpec {
    override func spec() {
        describe("absoluteStringWithoutProtocol") {
            it("returns the path of the url without the protocol") {
                let expectedPath = "stream/foo/bar"
                let path = "ello://" + expectedPath
                let url = NSURL(string: path)

                expect(url?.absoluteStringWithoutProtocol).to(equal(expectedPath))
            }
        }
    }
}
