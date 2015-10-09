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
        describe("ElloURI") {
            describe("baseURL") {

                it("can be constructed with ello-staging and http") {
                    ElloURI.domain = "ello-staging.herokuapp.com"
                    ElloURI.httpProtocol = "http"
                    expect(ElloURI.baseURL).to(equal("http://ello-staging.herokuapp.com"))
                }

                it("can be constructed with ello.co and https") {
                    ElloURI.domain = "ello.co"
                    ElloURI.httpProtocol = "https"
                    expect(ElloURI.baseURL).to(equal("https://ello.co"))
                }

            }

            describe("ElloURI.match on production") {

                beforeEach {
                    ElloURI.domain = "ello.co"
                    ElloURI.httpProtocol = "https"
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

                describe("with Profile Following urls") {

                    it("matches with http://ello.co/666/following") {
                        let (type, data) = ElloURI.match("http://ello.co/666/following")
                        expect(type).to(equal(ElloURI.ProfileFollowing))
                        expect(data).to(equal("666"))
                    }

                    it("matches with https://www.ello.co/420/following/") {
                        let (type, data) = ElloURI.match("https://www.ello.co/420/following/")
                        expect(type).to(equal(ElloURI.ProfileFollowing))
                        expect(data).to(equal("420"))
                    }
                    
                }

                describe("with Profile Followers urls") {

                    it("matches with http://ello.co/666/followers") {
                        let (type, data) = ElloURI.match("http://ello.co/666/followers")
                        expect(type).to(equal(ElloURI.ProfileFollowers))
                        expect(data).to(equal("666"))
                    }

                    it("matches with https://www.ello.co/420/followers/") {
                        let (type, data) = ElloURI.match("https://www.ello.co/420/followers/")
                        expect(type).to(equal(ElloURI.ProfileFollowers))
                        expect(data).to(equal("420"))
                    }
                    
                }
//case .Confirm, .ResetMyPassword, .FreedomOfSpeech, .FaceMaker, .Invitations, .Join, .Login, .PasswordResetError, .RandomSearch, .RequestInvitations, .SearchPeople, .SearchPosts, .ProfileFollowers, .ProfileFollowing, .DiscoverRandom, .DiscoverRelated, .Unblock:
//break
                describe("Confirm urls") {

                    it("matches with http://ello.co/confirm") {
                        let (type, _) = ElloURI.match("http://ello.co/confirm")
                        expect(type).to(equal(ElloURI.Confirm))
                    }

                    it("matches with http://ello.co/confirm/") {
                        let (type, _) = ElloURI.match("http://ello.co/confirm/")
                        expect(type).to(equal(ElloURI.Confirm))
                    }

                    it("does not match with http://ello.co/confirmYO") {
                        let (type, _) = ElloURI.match("http://ello.co/confirmYO")
                        expect(type).toNot(equal(ElloURI.Confirm))
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

                    it("matches with https://www.ello.co/420?expanded=false") {
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

                describe("with Search urls") {

                    it("matches with http://ello.co/search") {
                        let (type, data) = ElloURI.match("http://ello.co/search")
                        expect(type).to(equal(ElloURI.Search))
                        expect(data).to(equal(""))
                    }

                    it("matches with https://www.ello.co/search/") {
                        let (type, data) = ElloURI.match("https://www.ello.co/search/")
                        expect(type).to(equal(ElloURI.Search))
                        expect(data).to(equal(""))
                    }

                    it("does not match https://www.ello.co/searchyface") {
                        let (type, _) = ElloURI.match("https://www.ello.co/searchyface")
                        expect(type).notTo(equal(ElloURI.Search))
                    }

                    it("matches with https://ello.co/search?terms=%23hashtag") {
                        let (type, data) = ElloURI.match("https://ello.co/search?terms=%23hashtag")
                        expect(type).to(equal(ElloURI.Search))
                        expect(data).to(equal("#hashtag"))
                    }

                }

                describe("with Email addresses") {

                    it("matches with mailto:archer@example.com") {
                        let (type, data) = ElloURI.match("mailto:archer@example.com")
                        expect(type).to(equal(ElloURI.Email))
                        expect(data).to(equal("mailto:archer@example.com"))
                    }

                }

            }

            describe("ElloURI.match on staging") {

                beforeEach {
                    ElloURI.domain = "ello-staging.herokuapp.com"
                    ElloURI.httpProtocol = "https"
                }



// good --------------------------------------------------------------------------


                fdescribe("root urls") {

                    let domains = [
                        "http://ello.co",
                        "http://ello-staging.herokuapp.com",
                        "http://ello-staging2.herokuapp.com",
                        "http://staging.ello.co",
                        "https://ello.co",
                        "https://ello-staging.herokuapp.com",
                        "https://staging.ello.co",
                        "https://ello-staging2.herokuapp.com",
                    ]

                    describe("with domain urls") {
                        it("matches route correctly") {
                            for domain in domains {
                                let (type, data) = ElloURI.match(domain)

                                expect(type).to(equal(ElloURI.Root))
                                expect(data) == domain
                            }
                        }
                    }
                }

                fdescribe("specific urls") {
                    let tests: [String: (input: String, outputURI: ElloURI, outputData: String)] = [
                        "with Subdomain(short) urls": (input: "https://flowers.ello.co", outputURI: .Subdomain, outputData: "https://flowers.ello.co"),
                        "with Subdomain(long) urls": (input: "https://wallpapers.ello.co/any/thing/else/here", outputURI: .Subdomain, outputData: "https://wallpapers.ello.co/any/thing/else/here"),
                    ]

                    for (description, test) in tests {

                        describe(description) {
                            it("matches route correctly") {
                                let (type, data) = ElloURI.match(test.input)

                                expect(type).to(equal(test.outputURI))
                                expect(data) == test.outputData
                            }
                        }
                    }
                }

                describe("app loadable routes") {
                    let tests: [String: (input: String, outputURI: ElloURI, outputData: String)] = [
                        "with Profile urls": (input: "666", outputURI: .Profile, outputData: "666"),
                        "with Profile(query param) urls": (input: "666?expanded=true", outputURI: .Profile, outputData: "666"),
                        "with ProfileFollowers urls": (input: "777/followers", outputURI: .ProfileFollowers, outputData: "777"),
                        "with ProfileFollowing urls": (input: "888/following", outputURI: .ProfileFollowing, outputData: "888"),
                        "with Post urls": (input: "666/post/2345", outputURI: .Post, outputData: "2345"),
                        "with Post(query param) urls": (input: "777/post/123?expanded=true", outputURI: .Post, outputData: "123"),
                    ]

                    for (description, test) in tests {

                        describe(description) {
                            let domains = [
                                "http://ello.co",
                                "http://ello-staging.herokuapp.com",
                                "http://ello-staging2.herokuapp.com",
                                "http://staging.ello.co",
                                "https://ello.co",
                                "https://ello-staging.herokuapp.com",
                                "https://staging.ello.co",
                                "https://ello-staging2.herokuapp.com",
                            ]
                            it("matches route correctly") {

                                for domain in domains {
                                    let (typeNoSlash, dataNoSlash) = ElloURI.match("\(domain)/\(test.input)")

                                    expect(typeNoSlash).to(equal(test.outputURI))
                                    expect(dataNoSlash) == test.outputData

                                    let (typeYesSlash, dataYesSlash) = ElloURI.match("\(domain)/\(test.input)/")

                                    expect(typeYesSlash).to(equal(test.outputURI))
                                    expect(dataYesSlash) == test.outputData
                                }
                            }
                        }
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


                describe("known ello root routes") {
                    let tests: [String: (input: String, output: ElloURI)] = [
                        "with Confirm urls": (input: "confirm", output: .Confirm),
                        "with BetaPublicProfiles urls": (input: "beta-public-profiles", output: .BetaPublicProfiles),
                        "with Downloads urls": (input: "downloads", output: .Downloads),
                        "with Exit urls": (input: "exit", output: .Exit),
                        "with FaceMaker urls": (input: "facemaker", output: .FaceMaker),
                        "with ForgotMyPassword urls": (input: "forgot-my-password", output: .ForgotMyPassword),
                        "with FreedomOfSpeech urls": (input: "freedom-of-speech", output: .FreedomOfSpeech),
                        "with Invitations urls": (input: "invitations", output: .Invitations),
                        "with Join urls": (input: "join", output: .Join),
                        "with Login urls": (input: "login", output: .Login),
                        "with Manifesto urls": (input: "manifesto", output: .Manifesto),
                        "with PasswordResetError urls": (input: "password-reset-error", output: .PasswordResetError),
                        "with RandomSearch urls": (input: "random_searches", output: .RandomSearch),
                        "with RequestInvite urls": (input: "request-an-invite", output: .RequestInvite),
                        "with RequestInvitation urls": (input: "request-an-invitation", output: .RequestInvitation),
                        "with RequestInvitations urls": (input: "request_invitations", output: .RequestInvitations),
                        "with ResetMyPassword urls": (input: "reset-my-password", output: .ResetMyPassword),
                        "with Unblock urls": (input: "unblock", output: .Unblock),
                    ]

                    for (description, test) in tests {

                        describe(description) {
                            let domains = [
                                "http://ello.co",
                                "http://ello-staging.herokuapp.com",
                                "http://ello-staging2.herokuapp.com",
                                "http://staging.ello.co",
                                "https://ello.co",
                                "https://ello-staging.herokuapp.com",
                                "https://staging.ello.co",
                                "https://ello-staging2.herokuapp.com",
                            ]
                            it("matches route correctly") {

                                for domain in domains {
                                    let (typeNoSlash, dataNoSlash) = ElloURI.match("\(domain)/\(test.input)")

                                    expect(typeNoSlash).to(equal(test.output))
                                    expect(dataNoSlash) == "\(domain)/\(test.input)"

                                    let (typeYesSlash, dataYesSlash) = ElloURI.match("\(domain)/\(test.input)/")

                                    expect(typeYesSlash).to(equal(test.output))
                                    expect(dataYesSlash) == "\(domain)/\(test.input)/"

                                    let (typeTrailingChars, _) = ElloURI.match("\(domain)/\(test.input)foo")
                                    expect(typeTrailingChars).notTo(equal(test.output))
                                }
                            }
                        }
                    }
                }

// good done --------------------------------------------------------------------------

                describe("ello specific root routes") {
                    let tests: [String: (input: String, output: ElloURI)] = [
                        "with BetaPublicProfiles urls": (input: "beta-public-profiles", output: .BetaPublicProfiles),
                        "with Profile urls": (input: "666", output: .Profile),
                        //                        "with Discover urls": (input: "discover", output: ElloURI.Discover),
                        //                        "with Downloads urls": (input: "downloads", output: ElloURI.Downloads),
                        //                        "with Enter urls": (input: "enter", output: ElloURI.Enter),
                        //                        "with Exit urls": (input: "exit", output: ElloURI.Exit),
                        //                        "with ForgotMyPassword urls": (input: "forgot-my-password", output: ElloURI.ForgotMyPassword),
                        //                        "with Friends urls": (input: "friends", output: ElloURI.Friends),
                        //                        "with Manifesto urls": (input: "manifesto", output: ElloURI.Manifesto),
                        //                        "with Noise urls": (input: "noise", output: ElloURI.Noise),
                        //                        "with Notifications urls": (input: "notifications", output: ElloURI.Notifications),
                        //                        "with RequestInvitation urls": (input: "request-an-invitation", output: ElloURI.RequestInvitation),
                        //                        "with RequestInvite urls": (input: "request-an-invite", output: ElloURI.RequestInvite),
                        //                        "with Root urls": (input: "", output: ElloURI.Root),
                        //                        "with Settings urls": (input: "settings", output: ElloURI.Settings),
                        //                        "with WhoMadeThis urls": (input: "who-made-this", output: ElloURI.WhoMadeThis),
                        //                        "with WTF urls": (input: "wtf/help", output: ElloURI.WTF),
                        // http
                        // https
                    ]

                    for (description, test) in tests {
                        describe(description) {
                            let domains = ["http://ello.co", "http://ello-staging.herokuapp.com", "https://ello.co", "https://ello-staging.herokuapp.com"]
                            for domain in domains {

                                it("matches without trailing slash \(domain)/\(test.input)") {
                                    let (type, _) = ElloURI.match("\(domain)/\(test.input)")
                                    expect(type).to(equal(test.output))
                                }

                                it("matches with trailing slash \(domain)/\(test.input)/") {
                                    let (type, _) = ElloURI.match("\(domain)/\(test.input)/")
                                    expect(type).to(equal(test.output))
                                }
                                
                                it("does not match with \(domain)/\(test.input)foo") {
                                    let (type, _) = ElloURI.match("\(domain)/\(test.input)foo")
                                    expect(type).notTo(equal(test.output))
                                }
                            }
                        }
                    }
                }

                describe("with Search urls") {

                    it("matches with http://ello-staging.herokuapp.com/search") {
                        let (type, data) = ElloURI.match("http://ello-staging.herokuapp.com/search")
                        expect(type).to(equal(ElloURI.Search))
                        expect(data).to(equal(""))
                    }

                    it("matches with https://ello-staging5.herokuapp.com/search") {
                        let (type, data) = ElloURI.match("https://ello-staging5.herokuapp.com/search")
                        expect(type).to(equal(ElloURI.Search))
                        expect(data).to(equal(""))
                    }

                    it("matches with https://ello-staging.herokuapp.com/search?terms=%23hashtag") {
                        let (type, data) = ElloURI.match("https://ello-staging.herokuapp.com/search?terms=%23hashtag")
                        expect(type).to(equal(ElloURI.Search))
                        expect(data).to(equal("#hashtag"))
                    }
                }
            
            
            
            
                
                describe("with Subdomain urls") {
                    
                    it("matches with http://wallpapers.ello-staging.herokuapp.com") {
                        let (type, data) = ElloURI.match("http://wallpapers.ello-staging.herokuapp.com")
                        expect(type).to(equal(ElloURI.Subdomain))
                        expect(data).to(equal("http://wallpapers.ello-staging.herokuapp.com"))
                    }
                    
                    it("matches with https://wallpapers.ello-staging.herokuapp.com/any/thing/else/here") {
                        let (type, data) = ElloURI.match("https://wallpapers.ello-staging.herokuapp.com/any/thing/else/here")
                        expect(type).to(equal(ElloURI.Subdomain))
                        expect(data).to(equal("https://wallpapers.ello-staging.herokuapp.com/any/thing/else/here"))
                    }
                    
                }
            
            }
        }
    }
}
