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
                let str = "asdf"
                expect(str.urlEncoded()).to(equal("asdf"))
            }
            it("should encode 'a&/=' to 'a%26%2F%3D'") {
                let str = "a&/="
                expect(str.urlEncoded()).to(equal("a%26%2F%3D"))
            }
            it("should encode '…' to '%E2%80%A6'") {
                let str = "…"
                expect(str.urlEncoded()).to(equal("%E2%80%A6"))
            }
        }
        describe("decoding URL strings") {
            it("should decode 'asdf' to 'asdf'") {
                let str = "asdf"
                expect(str.urlDecoded()).to(equal("asdf"))
            }
            it("should decode 'a%26%2F%3D' to 'a&/='") {
                let str = "a%26%2F%3D"
                expect(str.urlDecoded()).to(equal("a&/="))
            }
            it("should decode '%E2%80%A6' to '…'") {
                let str = "%E2%80%A6"
                expect(str.urlDecoded()).to(equal("…"))
            }
        }
        describe("adding entities") {
            it("should handle 1-char length strings") {
                let str = "&"
                expect(str.entitiesEncoded()).to(equal("&amp;"))
            }
            it("should handle longer length strings") {
                let str = "black & blue"
                expect(str.entitiesEncoded()).to(equal("black &amp; blue"))
            }
            it("should handle many entities") {
                expect("&\"<>'".entitiesEncoded()).to(equal("&amp;&quot;&lt;&gt;&#039;"))
            }
            it("should handle many entities with strings") {
                expect("a & < c > == d".entitiesEncoded()).to(equal("a &amp; &lt; c &gt; == d"))
            }
        }
        describe("removing entities") {
            it("should handle 1-char length strings") {
                let str = "&amp;"
                expect(str.entitiesDecoded()).to(equal("&"))
            }
            it("should handle longer length strings") {
                let str = "black &amp; blue"
                expect(str.entitiesDecoded()).to(equal("black & blue"))
            }
            it("should handle many entities") {
                let str = "&amp; &lt;&gt; &pi;"
                expect(str.entitiesDecoded()).to(equal("& <> π"))
            }
            it("should handle many entities with strings") {
                let str = "a &amp; &lt; c &gt; &pi; == pi"
                expect(str.entitiesDecoded()).to(equal("a & < c > π == pi"))
            }
        }
        describe("salted sha1 hashing") {
            it("hashes the string using the sha1 algorithm with a prefixed salt value") {
                let str = "test"
                expect(str.saltedSHA1String) == "5bb3e61a51e40b8074716d2a30549c5b7b55cf63"
            }
        }
        describe("sha1 hashing") {
            it("hashes the string using the sha1 algorithm") {
                let str = "test"
                expect(str.SHA1String) == "a94a8fe5ccb19ba61c4c0873d391e987982fbbd3"
            }
        }
        describe("contains") {
            context("contains string") {
                it("returns true") {
                    let str = "test"
                    expect(str.contains("est")).to(beTrue())
                }
            }
            context("does not contain string") {
                it("returns false") {
                    let str = "test"
                    expect(str.contains("set")).to(beFalse())
                }
            }
        }
        describe("endsWith") {
            context("endsWith string") {
                it("returns true") {
                    let str = "test"
                    expect(str.endsWith("est")).to(beTrue())
                }
                it("returns true if string is repeated") {
                    let str = "test test"
                    expect(str.endsWith("est")).to(beTrue())
                }
            }
            context("does not endWith string") {
                it("returns false") {
                    let str = "test"
                    expect(str.endsWith("tes")).to(beFalse())
                }
            }
        }
        describe("beginsWith") {
            context("beginsWith string") {
                it("returns true") {
                    let str = "test"
                    expect(str.beginsWith("tes")).to(beTrue())
                }
                it("returns true if string is repeated") {
                    let str = "test test"
                    expect(str.beginsWith("tes")).to(beTrue())
                }
            }
            context("does not beginWith string") {
                it("returns false") {
                    let str = "test"
                    expect(str.beginsWith("est")).to(beFalse())
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
