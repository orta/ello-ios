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
                ElloURI.httpProtocol = "http"
                expect(ElloURI.baseURL).to(equal("http://ello-staging.herokuapp.com"))
            }

            it("uses production if AppSetup.sharedState.useStaging is false") {
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

            describe("with WTF urls") {

                it("matches with http://ello.co/wtf/help") {
                    let (type, data) = ElloURI.match("http://ello.co/wtf/help")
                    expect(type).to(equal(ElloURI.WTF))
                    expect(data).to(equal("http://ello.co/wtf/help"))
                }

                it("matches with https://www.ello.co/wtf") {
                    let (type, data) = ElloURI.match("https://www.ello.co/wtf")
                    expect(type).to(equal(ElloURI.WTF))
                    expect(data).to(equal("https://www.ello.co/wtf"))
                }
                
            }

            describe("with Discover urls") {

                it("matches with http://ello.co/discover") {
                    let (type, data) = ElloURI.match("http://ello.co/discover")
                    expect(type).to(equal(ElloURI.Discover))
                    expect(data).to(equal("http://ello.co/discover"))
                }

                it("matches with https://www.ello.co/discover") {
                    let (type, data) = ElloURI.match("https://www.ello.co/discover")
                    expect(type).to(equal(ElloURI.Discover))
                    expect(data).to(equal("https://www.ello.co/discover"))
                }

            }

            describe("with Downloads urls") {

                it("matches with http://ello.co/downloads") {
                    let (type, data) = ElloURI.match("http://ello.co/downloads")
                    expect(type).to(equal(ElloURI.Downloads))
                    expect(data).to(equal("http://ello.co/downloads"))
                }

                it("matches with https://www.ello.co/downloads") {
                    let (type, data) = ElloURI.match("https://www.ello.co/downloads")
                    expect(type).to(equal(ElloURI.Downloads))
                    expect(data).to(equal("https://www.ello.co/downloads"))
                }
                
            }

            describe("with Friends urls") {

                it("matches with http://ello.co/friends") {
                    let (type, data) = ElloURI.match("http://ello.co/friends")
                    expect(type).to(equal(ElloURI.Friends))
                    expect(data).to(equal("http://ello.co/friends"))
                }

                it("matches with https://www.ello.co/friends") {
                    let (type, data) = ElloURI.match("https://www.ello.co/friends")
                    expect(type).to(equal(ElloURI.Friends))
                    expect(data).to(equal("https://www.ello.co/friends"))
                }
                
            }

            describe("with Noise urls") {

                it("matches with http://ello.co/noise") {
                    let (type, data) = ElloURI.match("http://ello.co/noise")
                    expect(type).to(equal(ElloURI.Noise))
                    expect(data).to(equal("http://ello.co/noise"))
                }

                it("matches with https://www.ello.co/noise") {
                    let (type, data) = ElloURI.match("https://www.ello.co/noise")
                    expect(type).to(equal(ElloURI.Noise))
                    expect(data).to(equal("https://www.ello.co/noise"))
                }

            }

            describe("with Notifications urls") {

                it("matches with http://ello.co/notifications") {
                    let (type, data) = ElloURI.match("http://ello.co/notifications")
                    expect(type).to(equal(ElloURI.Notifications))
                    expect(data).to(equal("http://ello.co/notifications"))
                }

                it("matches with https://www.ello.co/notifications") {
                    let (type, data) = ElloURI.match("https://www.ello.co/notifications")
                    expect(type).to(equal(ElloURI.Notifications))
                    expect(data).to(equal("https://www.ello.co/notifications"))
                }
                
            }

            describe("with Search urls") {

                it("matches with http://ello.co/search") {
                    let (type, data) = ElloURI.match("http://ello.co/search")
                    expect(type).to(equal(ElloURI.Search))
                    expect(data).to(equal("http://ello.co/search"))
                }

                it("matches with https://www.ello.co/search") {
                    let (type, data) = ElloURI.match("https://www.ello.co/search")
                    expect(type).to(equal(ElloURI.Search))
                    expect(data).to(equal("https://www.ello.co/search"))
                }
                
            }

            describe("with Settings urls") {

                it("matches with http://ello.co/settings") {
                    let (type, data) = ElloURI.match("http://ello.co/settings")
                    expect(type).to(equal(ElloURI.Settings))
                    expect(data).to(equal("http://ello.co/settings"))
                }

                it("matches with https://www.ello.co/settings") {
                    let (type, data) = ElloURI.match("https://www.ello.co/settings")
                    expect(type).to(equal(ElloURI.Settings))
                    expect(data).to(equal("https://www.ello.co/settings"))
                }
                
            }

            describe("with Enter urls") {

                it("matches with http://ello.co/enter") {
                    let (type, data) = ElloURI.match("http://ello.co/enter")
                    expect(type).to(equal(ElloURI.Enter))
                    expect(data).to(equal("http://ello.co/enter"))
                }

                it("matches with https://www.ello.co/enter") {
                    let (type, data) = ElloURI.match("https://www.ello.co/enter")
                    expect(type).to(equal(ElloURI.Enter))
                    expect(data).to(equal("https://www.ello.co/enter"))
                }
                
            }

            describe("with Exit urls") {

                it("matches with http://ello.co/exit") {
                    let (type, data) = ElloURI.match("http://ello.co/exit")
                    expect(type).to(equal(ElloURI.Exit))
                    expect(data).to(equal("http://ello.co/exit"))
                }

                it("matches with https://www.ello.co/exit") {
                    let (type, data) = ElloURI.match("https://www.ello.co/exit")
                    expect(type).to(equal(ElloURI.Exit))
                    expect(data).to(equal("https://www.ello.co/exit"))
                }

            }

            describe("with BetaPublicProfiles urls") {

                it("matches with http://ello.co/beta-public-profiles") {
                    let (type, data) = ElloURI.match("http://ello.co/beta-public-profiles")
                    expect(type).to(equal(ElloURI.BetaPublicProfiles))
                    expect(data).to(equal("http://ello.co/beta-public-profiles"))
                }

                it("matches with https://www.ello.co/beta-public-profiles") {
                    let (type, data) = ElloURI.match("https://www.ello.co/beta-public-profiles")
                    expect(type).to(equal(ElloURI.BetaPublicProfiles))
                    expect(data).to(equal("https://www.ello.co/beta-public-profiles"))
                }
                
            }

            describe("with ForgotMyPassword urls") {

                it("matches with http://ello.co/forgot-my-password") {
                    let (type, data) = ElloURI.match("http://ello.co/forgot-my-password")
                    expect(type).to(equal(ElloURI.ForgotMyPassword))
                    expect(data).to(equal("http://ello.co/forgot-my-password"))
                }

                it("matches with https://www.ello.co/forgot-my-password") {
                    let (type, data) = ElloURI.match("https://www.ello.co/forgot-my-password")
                    expect(type).to(equal(ElloURI.ForgotMyPassword))
                    expect(data).to(equal("https://www.ello.co/forgot-my-password"))
                }
                
            }

            describe("with Manifesto urls") {

                it("matches with http://ello.co/manifesto") {
                    let (type, data) = ElloURI.match("http://ello.co/manifesto")
                    expect(type).to(equal(ElloURI.Manifesto))
                    expect(data).to(equal("http://ello.co/manifesto"))
                }

                it("matches with https://www.ello.co/manifesto") {
                    let (type, data) = ElloURI.match("https://www.ello.co/manifesto")
                    expect(type).to(equal(ElloURI.Manifesto))
                    expect(data).to(equal("https://www.ello.co/manifesto"))
                }
                
            }

            describe("with RequestInvite urls") {

                it("matches with http://ello.co/request-an-invite") {
                    let (type, data) = ElloURI.match("http://ello.co/request-an-invite")
                    expect(type).to(equal(ElloURI.RequestInvite))
                    expect(data).to(equal("http://ello.co/request-an-invite"))
                }

                it("matches with https://www.ello.co/request-an-invite") {
                    let (type, data) = ElloURI.match("https://www.ello.co/request-an-invite")
                    expect(type).to(equal(ElloURI.RequestInvite))
                    expect(data).to(equal("https://www.ello.co/request-an-invite"))
                }
                
            }

            describe("with RequestInvitation urls") {

                it("matches with http://ello.co/request-an-invitation") {
                    let (type, data) = ElloURI.match("http://ello.co/request-an-invitation")
                    expect(type).to(equal(ElloURI.RequestInvitation))
                    expect(data).to(equal("http://ello.co/request-an-invitation"))
                }

                it("matches with https://www.ello.co/request-an-invitation") {
                    let (type, data) = ElloURI.match("https://www.ello.co/request-an-invitation")
                    expect(type).to(equal(ElloURI.RequestInvitation))
                    expect(data).to(equal("https://www.ello.co/request-an-invitation"))
                }

            }

            describe("with WhoMadeThis urls") {

                it("matches with http://ello.co/who-made-this") {
                    let (type, data) = ElloURI.match("http://ello.co/who-made-this")
                    expect(type).to(equal(ElloURI.WhoMadeThis))
                    expect(data).to(equal("http://ello.co/who-made-this"))
                }

                it("matches with https://www.ello.co/who-made-this") {
                    let (type, data) = ElloURI.match("https://www.ello.co/who-made-this")
                    expect(type).to(equal(ElloURI.WhoMadeThis))
                    expect(data).to(equal("https://www.ello.co/who-made-this"))
                }
                
            }

            describe("with Email addresses") {

                it("matches with mailto:archer@example.com") {
                    let (type, data) = ElloURI.match("mailto:archer@example.com")
                    expect(type).to(equal(ElloURI.Email))
                    expect(data).to(equal("mailto:archer@example.com"))
                }
                
            }

            describe("with Subdomain urls") {

                it("matches with http://wallpapers.ello.co") {
                    let (type, data) = ElloURI.match("http://wallpapers.ello.co")
                    expect(type).to(equal(ElloURI.Subdomain))
                    expect(data).to(equal("http://wallpapers.ello.co"))
                }

                it("matches with https://wallpapers.ello.co/any/thing/else/here") {
                    let (type, data) = ElloURI.match("https://wallpapers.ello.co/any/thing/else/here")
                    expect(type).to(equal(ElloURI.Subdomain))
                    expect(data).to(equal("https://wallpapers.ello.co/any/thing/else/here"))
                }
                
            }

        }

        describe("ElloURI.match on staging") {

            beforeEach {
                ElloURI.domain = "ello-staging.herokuapp.com"
                ElloURI.httpProtocol = "https"
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

            describe("with WTF urls") {

                it("matches with http://ello-staging.herokuapp.com/wtf/help") {
                    let (type, data) = ElloURI.match("http://ello-staging.herokuapp.com/wtf/help")
                    expect(type).to(equal(ElloURI.WTF))
                    expect(data).to(equal("http://ello-staging.herokuapp.com/wtf/help"))
                }

                it("matches with https://ello-staging2.herokuapp.com/wtf") {
                    let (type, data) = ElloURI.match("https://ello-staging2.herokuapp.com/wtf")
                    expect(type).to(equal(ElloURI.WTF))
                    expect(data).to(equal("https://ello-staging2.herokuapp.com/wtf"))
                }

            }

            describe("with Discover urls") {

                it("matches with http://ello-staging.herokuapp.com/discover") {
                    let (type, data) = ElloURI.match("http://ello-staging.herokuapp.com/discover")
                    expect(type).to(equal(ElloURI.Discover))
                    expect(data).to(equal("http://ello-staging.herokuapp.com/discover"))
                }

                it("matches with https://ello-staging4.herokuapp.com/discover") {
                    let (type, data) = ElloURI.match("https://ello-staging4.herokuapp.com/discover")
                    expect(type).to(equal(ElloURI.Discover))
                    expect(data).to(equal("https://ello-staging4.herokuapp.com/discover"))
                }
                
            }

            describe("with Downloads urls") {

                it("matches with http://ello-staging.herokuapp.com/downloads") {
                    let (type, data) = ElloURI.match("http://ello-staging.herokuapp.com/downloads")
                    expect(type).to(equal(ElloURI.Downloads))
                    expect(data).to(equal("http://ello-staging.herokuapp.com/downloads"))
                }

                it("matches with https://ello-staging3.herokuapp.com/downloads") {
                    let (type, data) = ElloURI.match("https://ello-staging3.herokuapp.com/downloads")
                    expect(type).to(equal(ElloURI.Downloads))
                    expect(data).to(equal("https://ello-staging3.herokuapp.com/downloads"))
                }
                
            }

            describe("with Friends urls") {

                it("matches with http://ello-staging.herokuapp.com/friends") {
                    let (type, data) = ElloURI.match("http://ello-staging.herokuapp.com/friends")
                    expect(type).to(equal(ElloURI.Friends))
                    expect(data).to(equal("http://ello-staging.herokuapp.com/friends"))
                }

                it("matches with https://ello-staging2.herokuapp.com/friends") {
                    let (type, data) = ElloURI.match("https://ello-staging2.herokuapp.com/friends")
                    expect(type).to(equal(ElloURI.Friends))
                    expect(data).to(equal("https://ello-staging2.herokuapp.com/friends"))
                }

            }

            describe("with Noise urls") {

                it("matches with http://ello-staging.herokuapp.com/noise") {
                    let (type, data) = ElloURI.match("http://ello-staging.herokuapp.com/noise")
                    expect(type).to(equal(ElloURI.Noise))
                    expect(data).to(equal("http://ello-staging.herokuapp.com/noise"))
                }

                it("matches with https://ello-staging4.herokuapp.com/noise") {
                    let (type, data) = ElloURI.match("https://ello-staging4.herokuapp.com/noise")
                    expect(type).to(equal(ElloURI.Noise))
                    expect(data).to(equal("https://ello-staging4.herokuapp.com/noise"))
                }
                
            }

            describe("with Notifications urls") {

                it("matches with http://ello-staging.herokuapp.com/notifications") {
                    let (type, data) = ElloURI.match("http://ello-staging.herokuapp.com/notifications")
                    expect(type).to(equal(ElloURI.Notifications))
                    expect(data).to(equal("http://ello-staging.herokuapp.com/notifications"))
                }

                it("matches with https://ello-staging3.herokuapp.com/notifications") {
                    let (type, data) = ElloURI.match("https://ello-staging3.herokuapp.com/notifications")
                    expect(type).to(equal(ElloURI.Notifications))
                    expect(data).to(equal("https://ello-staging3.herokuapp.com/notifications"))
                }

            }

            describe("with Search urls") {

                it("matches with http://ello-staging.herokuapp.com/search") {
                    let (type, data) = ElloURI.match("http://ello-staging.herokuapp.com/search")
                    expect(type).to(equal(ElloURI.Search))
                    expect(data).to(equal("http://ello-staging.herokuapp.com/search"))
                }

                it("matches with https://ello-staging5.herokuapp.com/search") {
                    let (type, data) = ElloURI.match("https://ello-staging5.herokuapp.com/search")
                    expect(type).to(equal(ElloURI.Search))
                    expect(data).to(equal("https://ello-staging5.herokuapp.com/search"))
                }

            }

            describe("with Settings urls") {

                it("matches with http://ello-staging.herokuapp.com/settings") {
                    let (type, data) = ElloURI.match("http://ello-staging.herokuapp.com/settings")
                    expect(type).to(equal(ElloURI.Settings))
                    expect(data).to(equal("http://ello-staging.herokuapp.com/settings"))
                }

                it("matches with https://ello-staging2.herokuapp.com/settings") {
                    let (type, data) = ElloURI.match("https://ello-staging2.herokuapp.com/settings")
                    expect(type).to(equal(ElloURI.Settings))
                    expect(data).to(equal("https://ello-staging2.herokuapp.com/settings"))
                }
                
            }

            describe("with Enter urls") {

                it("matches with http://ello-staging.herokuapp.com/enter") {
                    let (type, data) = ElloURI.match("http://ello-staging.herokuapp.com/enter")
                    expect(type).to(equal(ElloURI.Enter))
                    expect(data).to(equal("http://ello-staging.herokuapp.com/enter"))
                }

                it("matches with https://ello-staging2.herokuapp.com/enter") {
                    let (type, data) = ElloURI.match("https://ello-staging2.herokuapp.com/enter")
                    expect(type).to(equal(ElloURI.Enter))
                    expect(data).to(equal("https://ello-staging2.herokuapp.com/enter"))
                }

            }

            describe("with Exit urls") {

                it("matches with http://ello-staging.herokuapp.com/exit") {
                    let (type, data) = ElloURI.match("http://ello-staging.herokuapp.com/exit")
                    expect(type).to(equal(ElloURI.Exit))
                    expect(data).to(equal("http://ello-staging.herokuapp.com/exit"))
                }

                it("matches with https://ello-staging2.herokuapp.com/exit") {
                    let (type, data) = ElloURI.match("https://ello-staging2.herokuapp.com/exit")
                    expect(type).to(equal(ElloURI.Exit))
                    expect(data).to(equal("https://ello-staging2.herokuapp.com/exit"))
                }

            }

            describe("with BetaPublicProfiles urls") {

                it("matches with http://ello-staging.herokuapp.com/beta-public-profiles") {
                    let (type, data) = ElloURI.match("http://ello-staging.herokuapp.com/beta-public-profiles")
                    expect(type).to(equal(ElloURI.BetaPublicProfiles))
                    expect(data).to(equal("http://ello-staging.herokuapp.com/beta-public-profiles"))
                }

                it("matches with https://ello-staging2.herokuapp.com/beta-public-profiles") {
                    let (type, data) = ElloURI.match("https://ello-staging2.herokuapp.com/beta-public-profiles")
                    expect(type).to(equal(ElloURI.BetaPublicProfiles))
                    expect(data).to(equal("https://ello-staging2.herokuapp.com/beta-public-profiles"))
                }

            }

            describe("with ForgotMyPassword urls") {

                it("matches with http://ello-staging.herokuapp.com/forgot-my-password") {
                    let (type, data) = ElloURI.match("http://ello-staging.herokuapp.com/forgot-my-password")
                    expect(type).to(equal(ElloURI.ForgotMyPassword))
                    expect(data).to(equal("http://ello-staging.herokuapp.com/forgot-my-password"))
                }

                it("matches with https://ello-staging2.herokuapp.com/forgot-my-password") {
                    let (type, data) = ElloURI.match("https://ello-staging2.herokuapp.com/forgot-my-password")
                    expect(type).to(equal(ElloURI.ForgotMyPassword))
                    expect(data).to(equal("https://ello-staging2.herokuapp.com/forgot-my-password"))
                }

            }

            describe("with Manifesto urls") {

                it("matches with http://ello-staging.herokuapp.com/manifesto") {
                    let (type, data) = ElloURI.match("http://ello-staging.herokuapp.com/manifesto")
                    expect(type).to(equal(ElloURI.Manifesto))
                    expect(data).to(equal("http://ello-staging.herokuapp.com/manifesto"))
                }

                it("matches with https://ello-staging2.herokuapp.com/manifesto") {
                    let (type, data) = ElloURI.match("https://ello-staging2.herokuapp.com/manifesto")
                    expect(type).to(equal(ElloURI.Manifesto))
                    expect(data).to(equal("https://ello-staging2.herokuapp.com/manifesto"))
                }

            }

            describe("with RequestInvite urls") {

                it("matches with http://ello-staging.herokuapp.com/request-an-invite") {
                    let (type, data) = ElloURI.match("http://ello-staging.herokuapp.com/request-an-invite")
                    expect(type).to(equal(ElloURI.RequestInvite))
                    expect(data).to(equal("http://ello-staging.herokuapp.com/request-an-invite"))
                }

                it("matches with https://ello-staging2.herokuapp.com/request-an-invite") {
                    let (type, data) = ElloURI.match("https://ello-staging2.herokuapp.com/request-an-invite")
                    expect(type).to(equal(ElloURI.RequestInvite))
                    expect(data).to(equal("https://ello-staging2.herokuapp.com/request-an-invite"))
                }

            }

            describe("with RequestInvitation urls") {

                it("matches with http://ello-staging.herokuapp.com/request-an-invitation") {
                    let (type, data) = ElloURI.match("http://ello-staging.herokuapp.com/request-an-invitation")
                    expect(type).to(equal(ElloURI.RequestInvitation))
                    expect(data).to(equal("http://ello-staging.herokuapp.com/request-an-invitation"))
                }

                it("matches with https://ello-staging2.herokuapp.com/request-an-invitation") {
                    let (type, data) = ElloURI.match("https://ello-staging2.herokuapp.com/request-an-invitation")
                    expect(type).to(equal(ElloURI.RequestInvitation))
                    expect(data).to(equal("https://ello-staging2.herokuapp.com/request-an-invitation"))
                }

            }

            describe("with WhoMadeThis urls") {

                it("matches with http://ello-staging.herokuapp.com/who-made-this") {
                    let (type, data) = ElloURI.match("http://ello-staging.herokuapp.com/who-made-this")
                    expect(type).to(equal(ElloURI.WhoMadeThis))
                    expect(data).to(equal("http://ello-staging.herokuapp.com/who-made-this"))
                }

                it("matches with https://ello-staging2.herokuapp.com/who-made-this") {
                    let (type, data) = ElloURI.match("https://ello-staging2.herokuapp.com/who-made-this")
                    expect(type).to(equal(ElloURI.WhoMadeThis))
                    expect(data).to(equal("https://ello-staging2.herokuapp.com/who-made-this"))
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
