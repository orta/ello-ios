//
//  SensitiveSettingsViewControllerSpec.swift
//  Ello
//
//  Created by Tony DiPasquale on 3/24/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Quick
import Nimble

class SensitiveSettingsViewControllerSpec: QuickSpec {
    override func spec() {
        var subject = SensitiveSettingsViewController.instantiateFromStoryboard()

        beforeSuite {
            ElloProvider.sharedProvider = ElloProvider.StubbingProvider()
        }

        afterSuite {
            ElloProvider.sharedProvider = ElloProvider.DefaultProvider()
        }

        beforeEach {
            subject = SensitiveSettingsViewController.instantiateFromStoryboard()
            subject.loadView()
        }

        describe("initialization") {
            describe("storyboard") {
                beforeEach {
                    subject.viewDidLoad()
                }

                it("IBOutlets are not nil") {
                    expect(subject.usernameField).notTo(beNil())
                    expect(subject.emailField).notTo(beNil())
                    expect(subject.passwordField).notTo(beNil())
                    expect(subject.currentPasswordField).notTo(beNil())
                }
            }
        }

        describe("viewDidLoad") {
            it("sets the text fields from the current user") {
                let user: User = stub(["username": "TestName", "email": "some@guy.com"])
                subject.currentUser = user
                subject.viewDidLoad()

                expect(subject.usernameField.text) == "TestName"
                expect(subject.emailField.text) == "some@guy.com"
                expect(subject.passwordField.text) == ""
            }
        }

        describe("isUpdatable") {
            beforeEach {
                let user: User = stub(["username": "TestName", "email": "some@guy.com"])
                subject.currentUser = user
                subject.viewDidLoad()
            }

            context("username") {
                context("is changed") {
                    it("isUpdatable is true") {
                        expect(subject.isUpdatable).to(beFalse())
                        subject.usernameField.text = "something"
                        subject.valueChanged()
                        expect(subject.isUpdatable).to(beTrue())
                    }
                }
                
                context("is reset") {
                    it("isUpdatable is false") {
                        subject.usernameField.text = "something"
                        subject.valueChanged()
                        expect(subject.isUpdatable).to(beTrue())
                        subject.usernameField.text = "TestName"
                        subject.valueChanged()
                        expect(subject.isUpdatable).to(beFalse())
                    }
                }
            }

            context("email") {
                context("is changed") {
                    it("isUpdatable is true") {
                        expect(subject.isUpdatable).to(beFalse())
                        subject.emailField.text = "no-one@email.com"
                        subject.valueChanged()
                        expect(subject.isUpdatable).to(beTrue())
                    }
                }
                
                context("is reset") {
                    it("isUpdatable is false") {
                        subject.emailField.text = "no-one@email.com"
                        subject.valueChanged()
                        expect(subject.isUpdatable).to(beTrue())
                        subject.emailField.text = "some@guy.com"
                        subject.valueChanged()
                        expect(subject.isUpdatable).to(beFalse())
                    }
                }
            }

            context("password") {
                context("is set") {
                    it("isUpdatable is true") {
                        expect(subject.isUpdatable).to(beFalse())
                        subject.passwordField.text = "anything"
                        subject.valueChanged()
                        expect(subject.isUpdatable).to(beTrue())
                    }
                }
                
                context("is empty") {
                    it("isUpdatable is false") {
                        subject.passwordField.text = "anything"
                        subject.valueChanged()
                        expect(subject.isUpdatable).to(beTrue())
                        subject.passwordField.text = ""
                        subject.valueChanged()
                        expect(subject.isUpdatable).to(beFalse())
                    }
                }
            }
        }

        describe("valueChanged") {
            beforeEach {
                subject.viewDidLoad()
            }

            it("calls the delegate function when set") {
                let fake = FakeSensitiveSettingsDelegate()
                subject.delegate = fake
                subject.valueChanged()
                expect(fake.didCall).to(beTrue())
            }
        }

        describe("height") {
            beforeEach {
                let user: User = stub(["username": "TestName", "email": "some@guy.com"])
                subject.currentUser = user
                subject.viewDidLoad()
            }

            context("isUpdatable is true") {
                it("returns 89 * 3 + 128") {
                    subject.passwordField.text = "anything"
                    expect(subject.isUpdatable).to(beTrue())
                    expect(subject.height) == 89 * 3 + 128
                }
            }

            context("isUpdatable is false") {
                it("returns 89 * 3") {
                    expect(subject.isUpdatable).to(beFalse())
                    expect(subject.height) == 89 * 3
                }
            }
        }
    }
}

class FakeSensitiveSettingsDelegate: SensitiveSettingsDelegate {
    var didCall = false

    func sensitiveSettingsDidUpdate() {
        didCall = true
    }
}
