//
//  RequestTypeSpec.swift
//  Ello
//
//  Created by Ryan Boyajian on 2/2/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Quick
import Nimble
import Moya

class RequestTypeSpec: QuickSpec {
    override func spec() {

        describe("@domain") {

            it("uses staging if AppSetup.sharedState.useStaging is true") {
                AppSetup.sharedState.useStaging = true
                expect(RequestType.domain).to(equal("ello-staging.herokuapp.com"))
            }

            xit("uses production if AppSetup.sharedState.useStaging is false") {
                AppSetup.sharedState.useStaging = false
                expect(RequestType.domain).to(equal("ello.co"))
            }

        }

        describe("RequestType.match") {

            // this is a hack to get this to work with prod
            beforeEach {
                RequestType.domain = "ello.co"
            }

            describe("with Post urls") {

                it("matches with http://ello.co/666/post/2345") {
                    let (type, data) = RequestType.match("http://ello.co/666/post/2345")
                    expect(type).to(equal(RequestType.Post))
                    expect(data).to(equal("2345"))
                }

                it("matches with https://www.ello.co/666/post/6789/") {
                    let (type, data) = RequestType.match("https://www.ello.co/666/post/6789/")
                    expect(type).to(equal(RequestType.Post))
                    expect(data).to(equal("6789"))
                }

            }

            describe("with Profile urls") {

                it("matches with http://ello.co/666") {
                    let (type, data) = RequestType.match("http://ello.co/666")
                    expect(type).to(equal(RequestType.Profile))
                    expect(data).to(equal("666"))
                }

                it("matches with https://www.ello.co/420/") {
                    let (type, data) = RequestType.match("https://www.ello.co/420/")
                    expect(type).to(equal(RequestType.Profile))
                    expect(data).to(equal("420"))
                }
                
            }

            describe("with External urls") {

                it("matches with http://google.com") {
                    let (type, data) = RequestType.match("http://www.google.com")
                    expect(type).to(equal(RequestType.External))
                    expect(data).to(equal("http://www.google.com"))
                }

                it("matches with https://www.vimeo.com/anything/") {
                    let (type, data) = RequestType.match("https://www.vimeo.com/anything/")
                    expect(type).to(equal(RequestType.External))
                    expect(data).to(equal("https://www.vimeo.com/anything/"))
                }
                
            }

        }

    }
}
