//
//  TagSpec.swift
//  Ello
//
//  Created by Colin Gray on 7/31/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Quick
import Nimble
import Ello


class TagSpec: QuickSpec {
    override func spec() {
        fdescribe("Tag") {
            let tests: [String: (input: String, output: String)] = [
                "break tags": (input: "test<br><br />", output: "test<br /><br />"),
                "break tags in a p tag": (input: "<p>test<br><br />", output: "<p>test<br /><br /></p>"),
                "entities": (input: "&lt;tag!&gt;that is a tag&lt;/tag&gt;", output: "&lt;tag!&gt;that is a tag&lt;/tag&gt;"),
                "link": (input: "test <a href=\"foo.com\">a link</a>", output: "test <a href=\"foo.com\">a link</a>"),
                "styled text": (input: "test <b>bold</b> <i>italic</i> <strong>strong</strong> <em>emphasis</em>", output: "test <b>bold</b> <i>italic</i> <strong>strong</strong> <em>emphasis</em>")
            ]
            for (name, spec) in tests {
                it("should parse \(name)") {
                    let text = Tag(input: spec.input)
                    expect(text!.description) == spec.output
                }
            }

        }
    }
}
