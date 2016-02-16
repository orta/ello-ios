//
//  NSAttributedStringSpec.swift
//  Ello
//
//  Created by Colin Gray on 2/2/2016.
//  Copyright (c) 2016 Ello. All rights reserved.
//

@testable import Ello
import Quick
import Nimble


class NSAttributedStringSpec: QuickSpec {
    override func spec() {
        fdescribe("NSAttributedString") {
            describe("joinWithNewlines(_: NSAttributedString)") {
                it("can insert two newlines") {
                    let subject1 = NSAttributedString(string: "one")
                    let subject2 = NSAttributedString(string: "two")
                    let joined = subject1.joinWithNewlines(subject2)
                    expect(joined.string) == "one\n\ntwo"
                }
                it("can insert one newline") {
                    let subject1 = NSAttributedString(string: "one\n")
                    let subject2 = NSAttributedString(string: "two")
                    let joined = subject1.joinWithNewlines(subject2)
                    expect(joined.string) == "one\n\ntwo"
                }
                it("can insert zero newlines") {
                    let subject1 = NSAttributedString(string: "one\n\n")
                    let subject2 = NSAttributedString(string: "two")
                    let joined = subject1.joinWithNewlines(subject2)
                    expect(joined.string) == "one\n\ntwo"
                }
            }
        }
    }
}
