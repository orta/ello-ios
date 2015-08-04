//
//  KoffeeSpec.swift
//  Ello
//
//  Created by Colin Gray on 7/31/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Quick
import Nimble
import Ello


class KoffeeSpec: QuickSpec {
    override func spec() {
        describe("Koffee") {
            let tests: [String: String] = [
                "test<br><br />": "test\n\n",
                "test <a href=\"foo.com\">a link</a>": "test [a link](foo.com)",
                "test <b>bold</b> <i>italic</i> <strong>strong</strong> <em>emphasis</em>": "test bold italic strong emphasis"
            ]
            for (input, output) in tests {
                it("should parse html") {
                    let tag = koffee(input)
                    expect(tag!.makeEditable().string) == output
                }
            }

        }
    }
}
