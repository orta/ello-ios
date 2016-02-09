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
        describe("AutoComplete") {

            let subject = AutoComplete()

            describe("check(_:location)") {

                context("username") {
                    it("returns the correct character range and string") {
                        let str = "@sean"
                        let result = subject.check(str, location: 2)

                        expect(result?.type) == AutoCompleteType.Username
                        expect(result?.range) == str.startIndex..<str.startIndex.advancedBy(3)
                        expect(result?.text) == "@se"
                    }
                }

                context("username in long string") {
                    it("returns the correct character range and string") {
                        let str = "hi there @sean"
                        let result = subject.check(str, location: 12)

                        expect(result?.type) == AutoCompleteType.Username
                        expect(result?.range) == str.startIndex.advancedBy(9)..<str.startIndex.advancedBy(13)
                        expect(result?.text) == "@sea"
                    }
                }

                context("emoji") {
                    fit("returns the correct character range and string") {
                        let str = "start :emoji"
                        let result = subject.check(str, location: 9)

                        expect(result?.type) == AutoCompleteType.Emoji
                        expect(result?.range) == str.startIndex.advancedBy(6)..<str.startIndex.advancedBy(10)
                        expect(result?.text) == ":emo"
                    }
                }

                context("double emoji") {
                    fit("returns the 2nd emoji word part") {
                        let str = "some long sentence :start::thumbsup"
                        let result = subject.check(str, location: 29)

                        expect(result?.type) == AutoCompleteType.Emoji
                        expect(result?.range) == str.startIndex.advancedBy(26)..<str.startIndex.advancedBy(30)
                        expect(result?.text) == ":thu"
                    }
                }

                context("location at the end of the string") {
                    it("returns the correct character range and string") {
                        let str = "@hi"
                        let result = subject.check(str, location: 2)

                        expect(result?.type) == AutoCompleteType.Username
                        expect(result?.range) == str.startIndex..<str.startIndex.advancedBy(3)
                        expect(result?.text) == "@hi"
                    }
                }

                context("whitespace after a match") {
                    it("returns nil") {
                        let str = "@username "
                        let result = subject.check(str, location: 9)

                        expect(result).to(beNil())
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

                context("emoji already in string") {
                    it("returns nil") {
                        let str = ":+1:two"
                        let result = subject.check(str, location: 6)

                        expect(result).to(beNil())
                    }
                }
            }
        }
    }
}
