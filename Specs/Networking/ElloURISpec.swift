//
//  ElloURISpec.swift
//  Ello
//
//  Created by Ryan Boyajian on 2/2/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble
import Moya


class ElloURISpec: QuickSpec {
    override func spec() {

        describe("@domain") {

            it("uses staging if AppSetup.sharedState.useStaging is true") {
                ElloURI.domain = "ello-staging.herokuapp.com"
                expect(ElloURI.baseURL).to(equal("https://ello-staging.herokuapp.com"))
            }

            it("uses production if AppSetup.sharedState.useStaging is false") {
                ElloURI.domain = "ello.co"
                expect(ElloURI.baseURL).to(equal("https://ello.co"))
            }

        }

        describe("ElloURI.match on production") {

            beforeEach {
                ElloURI.domain = "ello.co"
            }

            describe("with Post urls") {

                it("matches with http://ello.co/666/post/2345") {
                    let (type, data) = ElloURI.match("http://ello.co/666/post/2345")
                    expect(type).to(equal(ElloURI.Post))
                    expect(data).to(equal("2345"))
                }

                it("matches with https://www.ello.co/666/post/6789/") {
                    let (type, data) = ElloURI.match("https://www.ello.co/666/post/6789/")
                    expect(type).to(equal(ElloURI.Post))
                    expect(data).to(equal("6789"))
                }

                it("matches with https://www.ello.co/666/post/6789?expanded=true") {
                    let (type, data) = ElloURI.match("https://www.ello.co/666/post/6789/")
                    expect(type).to(equal(ElloURI.Post))
                    expect(data).to(equal("6789"))
                }

            }

            describe("with Profile urls") {

                it("matches with http://ello.co/666") {
                    let (type, data) = ElloURI.match("http://ello.co/666")
                    expect(type).to(equal(ElloURI.Profile))
                    expect(data).to(equal("666"))
                }

                it("matches with https://www.ello.co/420/") {
                    let (type, data) = ElloURI.match("https://www.ello.co/420/")
                    expect(type).to(equal(ElloURI.Profile))
                    expect(data).to(equal("420"))
                }

                it("matches with https://www.ello.co/420/") {
                    let (type, data) = ElloURI.match("https://www.ello.co/420?expanded=false")
                    expect(type).to(equal(ElloURI.Profile))
                    expect(data).to(equal("420"))
                }

            }

            describe("with External urls") {

                it("matches with http://google.com") {
                    let (type, data) = ElloURI.match("http://www.google.com")
                    expect(type).to(equal(ElloURI.External))
                    expect(data).to(equal("http://www.google.com"))
                }

                it("matches with https://www.vimeo.com/anything/") {
                    let (type, data) = ElloURI.match("https://www.vimeo.com/anything/")
                    expect(type).to(equal(ElloURI.External))
                    expect(data).to(equal("https://www.vimeo.com/anything/"))
                }
                
            }

        }

        describe("ElloURI.match on staging") {

            beforeEach {
                ElloURI.domain = "ello-staging.herokuapp.com"
            }

            describe("with Post urls") {

                it("matches with http://ello-staging.herokuapp.com/666/post/2345") {
                    let (type, data) = ElloURI.match("http://ello-staging.herokuapp.com/666/post/2345")
                    expect(type).to(equal(ElloURI.Post))
                    expect(data).to(equal("2345"))
                }

                it("matches with http://ello-staging.herokuapp.com/666/post/2345?expanded=false") {
                    let (type, data) = ElloURI.match("http://ello-staging.herokuapp.com/666/post/2345")
                    expect(type).to(equal(ElloURI.Post))
                    expect(data).to(equal("2345"))
                }

            }

            describe("with Profile urls") {

                it("matches with http://ello-staging.herokuapp.com/666") {
                    let (type, data) = ElloURI.match("http://ello-staging.herokuapp.com/666")
                    expect(type).to(equal(ElloURI.Profile))
                    expect(data).to(equal("666"))
                }

                it("matches with http://ello-staging.herokuapp.com/666") {
                    let (type, data) = ElloURI.match("http://ello-staging.herokuapp.com/666?expanded=true")
                    expect(type).to(equal(ElloURI.Profile))
                    expect(data).to(equal("666"))
                }

            }

            describe("with External urls") {

                it("matches with http://google.com") {
                    let (type, data) = ElloURI.match("http://www.google.com")
                    expect(type).to(equal(ElloURI.External))
                    expect(data).to(equal("http://www.google.com"))
                }

                it("matches with https://www.vimeo.com/anything/") {
                    let (type, data) = ElloURI.match("https://www.vimeo.com/anything/")
                    expect(type).to(equal(ElloURI.External))
                    expect(data).to(equal("https://www.vimeo.com/anything/"))
                }                
            }
        }
    }
}
