//
//  JoinViewControllerSpec.swift
//  Ello
//
//  Created by Sean on 1/6/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

@testable
import Ello
import Quick
import Nimble


class JoinViewControllerSpec: QuickSpec {
    override func spec() {

        beforeSuite {
            ElloProvider.sharedProvider = ElloProvider.StubbingProvider()
        }

        afterSuite {
            ElloProvider.sharedProvider = ElloProvider.DefaultProvider()
        }

        describe("JoinViewController") {
            var subject: JoinViewController!

            beforeEach {
                ElloProvider.sharedProvider = ElloProvider.StubbingProvider()
                let keychain = FakeKeychain()
                keychain.authToken = "abcde"
                keychain.authTokenExpires = NSDate().dateByAddingTimeInterval(3600)
                keychain.authTokenType = "grant"
                keychain.refreshAuthToken = "abcde"
                keychain.isAuthenticated = true
                AuthToken.sharedKeychain = keychain

                subject = JoinViewController()
                showController(subject)
            }

            afterEach {
                AuthToken.sharedKeychain = Keychain()
            }

            describe("initialization") {

                it("can be instantiated from storyboard") {
                    expect(subject).notTo(beNil())
                }

                it("is a BaseElloViewController") {
                    expect(subject).to(beAKindOf(BaseElloViewController.self))
                }

                it("is a JoinViewController") {
                    expect(subject).to(beAKindOf(JoinViewController.self))
                }
            }

            describe("storyboard") {

                it("IBOutlets are  not nil") {
                    expect(subject.scrollView).notTo(beNil())
                    expect(subject.emailField).notTo(beNil())
                    expect(subject.usernameField).notTo(beNil())
                    expect(subject.passwordField).notTo(beNil())
                    expect(subject.onePasswordButton).notTo(beNil())
                    expect(subject.loginButton).notTo(beNil())
                    expect(subject.joinButton).notTo(beNil())
                    expect(subject.termsButton).notTo(beNil())
                }

                it("IBActions are wired up") {
                    let onePasswordActions = subject.onePasswordButton.actionsForTarget(subject, forControlEvent: UIControlEvents.TouchUpInside)
                    expect(onePasswordActions).to(contain("findLoginFrom1Password:"))
                    expect(onePasswordActions?.count) == 1

                    let loginActions = subject.loginButton.actionsForTarget(subject, forControlEvent: UIControlEvents.TouchUpInside)
                    expect(loginActions).to(contain("loginTapped:"))
                    expect(loginActions?.count) == 1

                    let joinActions = subject.joinButton.actionsForTarget(subject, forControlEvent: UIControlEvents.TouchUpInside)
                    expect(joinActions).to(contain("joinTapped:"))
                    expect(joinActions?.count) == 1
                }
            }

            describe("submitting successful credentials") {
                it("stores the email and password") {
                    let email = "email@email.com"
                    let username = "username"
                    let password = "password"
                    subject.emailField.text = email
                    subject.usernameField.text = username
                    subject.passwordField.text = password
                    subject.join()

                    let token = AuthToken()
                    expect(token.username) == email
                    expect(token.password) == password
                }
            }

            describe("validation") {

                beforeEach {
                    subject = JoinViewController()
                    showController(subject)
                }

                describe("initial state") {
                    it("starts with joinButton enabled") {
                        expect(subject.joinButton.enabled) == true
                    }
                    it("starts with empty messages") {
                        expect(subject.emailField.text ?? "") == ""
                        expect(subject.usernameField.text ?? "") == ""
                        expect(subject.passwordField.text ?? "") == ""
                    }
                    it("has all the views located sensibly") {
                        // expect(subject.emailView).toBeBelow(130)
                        expect(subject.emailField.frame.minY) > 130
                        expect(subject.usernameField.frame.height) == subject.emailField.frame.height
                        expect(subject.passwordField.frame.height) == subject.emailField.frame.height
                    }
                }

            }
        }
    }
}
