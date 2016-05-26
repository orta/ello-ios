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

            describe("eagerCheck(_:location)") {
                context("empty") {
                    it("returns false") {
                        let str = ""
                        let result = subject.eagerCheck(str, location: 0)

                        expect(result) == false
                    }
                }

                context("single space") {
                    it("returns false") {
                        let str = " "
                        let result = subject.eagerCheck(str, location: 0)

                        expect(result) == false
                    }
                }

                context("at") {
                    it("returns true") {
                        let str = "@"
                        let result = subject.eagerCheck(str, location: 0)

                        expect(result) == true
                    }
                }

                context("at in middle of string") {
                    it("returns true") {
                        let str = " @"
                        let result = subject.eagerCheck(str, location: 1)

                        expect(result) == true
                    }
                }

                context("username") {
                    it("returns true") {
                        let str = "@sean"
                        let result = subject.eagerCheck(str, location: 2)

                        expect(result) == true
                    }
                }

                context("username in long string") {
                    it("returns true") {
                        let str = "hi there @sean"
                        let result = subject.eagerCheck(str, location: 12)

                        expect(result) == true
                    }
                }

                context("colon") {
                    it("returns true") {
                        let str = ":"
                        let result = subject.eagerCheck(str, location: 0)

                        expect(result) == true
                    }
                }

                context("colon in middle of string") {
                    it("returns true") {
                        let str = " :"
                        let result = subject.eagerCheck(str, location: 1)

                        expect(result) == true
                    }
                }

                context("colon at end of word") {
                    it("returns true") {
                        let str = "list:"
                        let result = subject.eagerCheck(str, location: 5)

                        expect(result) == false
                    }
                }

                context("emoji") {
                    it("returns true") {
                        let str = "start :emoji"
                        let result = subject.eagerCheck(str, location: 9)

                        expect(result) == true
                    }
                }

                context("end of emoji") {
                    it("returns false") {
                        let str = "start :emoji:"
                        let result = subject.eagerCheck(str, location: 13)

                        expect(result) == false
                    }
                }

                context("double emoji") {
                    it("returns the 2nd emoji word part") {
                        let str = "some long sentence :start::thumbsup"
                        let result = subject.eagerCheck(str, location: 29)

                        expect(result) == true
                    }
                }

                context("location at the end of the string") {
                    it("returns the correct character range and string") {
                        let str = "@hi"
                        let result = subject.eagerCheck(str, location: 2)

                        expect(result) == true
                    }
                }

                context("whitespace after a match") {
                    it("returns false") {
                        let str = "@username "
                        let result = subject.eagerCheck(str, location: 9)

                        expect(result) == false
                    }
                }

                context("neither") {
                    it("returns false") {
                        let str = "nothing here to find"
                        let result = subject.eagerCheck(str, location: 8)

                        expect(result) == false
                    }
                }

                context("location out of bounds") {
                    it("returns false") {
                        let str = "hi"
                        let result = subject.eagerCheck(str, location: 100)

                        expect(result) == false
                    }
                }

                context("location one past the end") {
                    it("returns false") {
                        let str = ":hi"
                        let result = subject.eagerCheck(str, location: 3)

                        expect(result) == false
                    }
                }

                context("email address") {
                    it("returns false") {
                        let str = "joe@example"
                        let result = subject.eagerCheck(str, location: 9)

                        expect(result) == false
                    }
                }

                context("emoji already in string") {
                    it("returns false") {
                        let str = ":+1:two"
                        let result = subject.eagerCheck(str, location: 6)

                        expect(result) == false
                    }
                }
            }

            describe("check(_:location)") {

                context("empty") {
                    it("returns nil") {
                        let str = ""
                        let result = subject.check(str, location: 0)

                        expect(result).to(beNil())
                    }
                }

                context("single space") {
                    it("returns nil") {
                        let str = " "
                        let result = subject.check(str, location: 0)

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

                context("colon at end of word") {
                    it("returns nil") {
                        let str = "list:"
                        let result = subject.check(str, location: 5)

                        expect(result).to(beNil())
                    }
                }

                context("emoji") {
                    it("returns the correct character range and string") {
                        let str = "start :emoji"
                        let result = subject.check(str, location: 9)

                        expect(result?.type) == AutoCompleteType.Emoji
                        expect(result?.range) == str.startIndex.advancedBy(6)..<str.startIndex.advancedBy(10)
                        expect(result?.text) == ":emo"
                    }
                }

                context("end of emoji") {
                    it("returns nil") {
                        let str = "start :emoji:"
                        let result = subject.check(str, location: 13)

                        expect(result).to(beNil())
                    }
                }

                context("double emoji") {
                    it("returns the 2nd emoji word part") {
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

                context("emoji already in string, started new emoji") {
                    it("returns :two when separated by space") {
                        let str = ":+1: :two"
                        let result = subject.check(str, location: 8)

                        expect(result?.type) == AutoCompleteType.Emoji
                        expect(result?.range) == str.startIndex.advancedBy(5)..<str.startIndex.advancedBy(9)
                        expect(result?.text) == ":two"
                    }
                    it("returns :two when emojis are touching") {
                        let str = ":+1::two"
                        let result = subject.check(str, location: 7)

                        expect(result?.type) == AutoCompleteType.Emoji
                        expect(result?.range) == str.startIndex.advancedBy(4)..<str.startIndex.advancedBy(8)
                        expect(result?.text) == ":two"
                    }
                }
            }
        }
    }
}
