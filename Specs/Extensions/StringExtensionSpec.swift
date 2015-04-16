//
//  StringExtensionSpec.swift
//  Ello
//
//  Created by Colin Gray on 3/4/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble


class StringExtensionSpec: QuickSpec {
    override func spec() {
        describe("encoding URL strings") {
            it("should encode 'asdf' to 'asdf'") {
                expect("asdf".urlEncoded()).to(equal("asdf"))
            }
            it("should encode 'a&/=' to 'a%26%2F%3D'") {
                expect("a&/=".urlEncoded()).to(equal("a%26%2F%3D"))
            }
            it("should encode '…' to '%E2%80%A6'") {
                expect("…".urlEncoded()).to(equal("%E2%80%A6"))
            }
        }
        describe("decoding URL strings") {
            it("should decode 'asdf' to 'asdf'") {
                expect("asdf".urlDecoded()).to(equal("asdf"))
            }
            it("should decode 'a%26%2F%3D' to 'a&/='") {
                expect("a%26%2F%3D".urlDecoded()).to(equal("a&/="))
            }
            it("should decode '%E2%80%A6' to '…'") {
                expect("%E2%80%A6".urlDecoded()).to(equal("…"))
            }
        }
        describe("adding entities") {
            it("should handle 1-char length strings") {
                expect("&".entitiesEncoded()).to(equal("&amp;"))
            }
            it("should handle longer length strings") {
                expect("black & blue".entitiesEncoded()).to(equal("black &amp; blue"))
            }
            it("should handle many entities") {
                expect("& <> π".entitiesEncoded()).to(equal("&amp; &lt;&gt; &pi;"))
            }
            it("should handle many entities with strings") {
                expect("a & < c > π == pi".entitiesEncoded()).to(equal("a &amp; &lt; c &gt; &pi; == pi"))
            }
        }
        describe("removing entities") {
            it("should handle 1-char length strings") {
                expect("&amp;".entitiesDecoded()).to(equal("&"))
            }
            it("should handle longer length strings") {
                expect("black &amp; blue".entitiesDecoded()).to(equal("black & blue"))
            }
            it("should handle many entities") {
                expect("&amp; &lt;&gt; &pi;".entitiesDecoded()).to(equal("& <> π"))
            }
            it("should handle many entities with strings") {
                expect("a &amp; &lt; c &gt; &pi; == pi".entitiesDecoded()).to(equal("a & < c > π == pi"))
            }
        }
        describe("sha1 hashing") {
            it("hashes the string using the sha1 algorithm") {
                expect("test".SHA1String) == "5bb3e61a51e40b8074716d2a30549c5b7b55cf63"
            }
        }
        describe("contains") {
            context("contains string") {
                it("returns true") {
                    expect("test".contains("est")).to(beTrue())
                }
            }
            context("does not contain string") {
                it("returns false") {
                    expect("test".contains("set")).to(beFalse())
                }
            }
        }
        describe("camelCase") {
            it("converts a string from snake case to camel case") {
                let snake = "sssss_sssss"
                expect(snake.camelCase) == "sssssSssss"
            }
        }
    }
}
