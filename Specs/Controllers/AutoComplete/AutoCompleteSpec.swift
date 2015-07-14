//
//  AutoCompleteSpec.swift
//  Ello
//
//  Created by Sean on 7/13/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble

import Result

class AutoCompleteSpec: QuickSpec {
    override func spec() {
        fdescribe("AutoComplete") {

            let subject = AutoComplete()

            describe("check(_:location)") {

                context("username") {
                    it("returns the correct character range and string") {
                        let str = "@sean"
                        let result = subject.check(str, location: 2)

                        expect(result?.type) == AutoCompleteType.Username
                        expect(result?.range) == str.startIndex..<advance(str.startIndex, 3)
                        expect(result?.text) == "@se"
                    }
                }

                context("emoji") {
                    it("returns the correct character range and string") {
                        let str = "start :emoji"
                        let result = subject.check(str, location: 9)

                        expect(result?.type) == AutoCompleteType.Emoji
                        expect(result?.range) == advance(str.startIndex, 6)..<advance(str.startIndex, 10)
                        expect(result?.text) == ":emo"
                    }
                }

                context("location at the end of the string") {
                    it("returns the correct character range and string") {
                        let str = ":hi"
                        let result = subject.check(str, location: 2)

                        expect(result?.type) == AutoCompleteType.Emoji
                        expect(result?.range) == str.startIndex..<advance(str.startIndex, 3)
                        expect(result?.text) == ":hi"
                    }
                }

                context("neither") {
                    it("returns nil") {
                        let str = "nothing here to find"
                        let result = subject.check(str, location: 8)

                        expect(result).to(beNil())
                    }
                }

                context("empty string") {
                    it("returns nil") {
                        let str = ""
                        let result = subject.check(str, location: 0)

                        expect(result).to(beNil())
                    }
                }


                context("location out of bounds") {
                    it("returns nil") {
                        let str = "hi"
                        let result = subject.check(str, location: 100)

                        expect(result).to(beNil())
                    }
                }

                context("location one past the end") {
                    it("returns nil") {
                        let str = ":hi"
                        let result = subject.check(str, location: 3)

                        expect(result).to(beNil())
                    }
                }

                context("email address") {
                    it("returns nil") {
                        let str = "joe@example"
                        let result = subject.check(str, location: 9)

                        expect(result).to(beNil())
                    }
                }
            }
        }
    }
}
