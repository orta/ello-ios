//
//  CredentialSettingsViewControllerSpec.swift
//  Ello
//
//  Created by Tony DiPasquale on 3/24/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble


class CredentialSettingsViewControllerSpec: QuickSpec {
    override func spec() {
        var subject = CredentialSettingsViewController.instantiateFromStoryboard()

        beforeEach {
            subject = CredentialSettingsViewController.instantiateFromStoryboard()
            subject.loadView()
        }

        describe("initialization") {
            describe("storyboard") {
                beforeEach {
                    subject.viewDidLoad()
                }

                it("IBOutlets are not nil") {
                    expect(subject.usernameView).notTo(beNil())
                    expect(subject.emailView).notTo(beNil())
                    expect(subject.passwordView).notTo(beNil())
                    expect(subject.currentPasswordField).notTo(beNil())
                    expect(subject.errorLabel).notTo(beNil())
                    expect(subject.saveButton).notTo(beNil())
                }
            }
        }

        describe("viewDidLoad") {
            it("sets the text fields from the current user") {
                let user: User = stub(["username": "TestName", "profile": Profile.stub(["email": "some@guy.com"])])
                subject.currentUser = user
                subject.viewDidLoad()

                expect(subject.usernameView.textField.text) == "TestName"
                expect(subject.emailView.textField.text) == "some@guy.com"
                expect(subject.passwordView.textField.text) == ""
            }
        }

        describe("isUpdatable") {
            beforeEach {
                let user: User = stub(["username": "TestName", "profile": Profile.stub(["email": "some@guy.com"])])
                subject.currentUser = user
                subject.viewDidLoad()
            }

            context("username") {
                context("is changed") {
                    it("isUpdatable is true") {
                        expect(subject.isUpdatable).to(beFalse())
                        subject.usernameView.textField.text = "something"
                        expect(subject.isUpdatable).to(beTrue())
                    }
                }

                context("is reset") {
                    it("isUpdatable is false") {
                        subject.usernameView.textField.text = "something"
                        expect(subject.isUpdatable).to(beTrue())
                        subject.usernameView.textField.text = "TestName"
                        expect(subject.isUpdatable).to(beFalse())
                    }
                }
            }

            context("email") {
                context("is changed") {
                    it("isUpdatable is true") {
                        expect(subject.isUpdatable).to(beFalse())
                        subject.emailView.textField.text = "no-one@email.com"
                        expect(subject.isUpdatable).to(beTrue())
                    }
                }

                context("is reset") {
                    it("isUpdatable is false") {
                        subject.emailView.textField.text = "no-one@email.com"
                        expect(subject.isUpdatable).to(beTrue())
                        subject.emailView.textField.text = "some@guy.com"
                        expect(subject.isUpdatable).to(beFalse())
                    }
                }
            }

            context("password") {
                context("is set") {
                    it("isUpdatable is true") {
                        expect(subject.isUpdatable).to(beFalse())
                        subject.passwordView.textField.text = "anything"
                        expect(subject.isUpdatable).to(beTrue())
                    }
                }

                context("is empty") {
                    it("isUpdatable is false") {
                        subject.passwordView.textField.text = "anything"
                        expect(subject.isUpdatable).to(beTrue())
                        subject.passwordView.textField.text = ""
                        expect(subject.isUpdatable).to(beFalse())
                    }
                }
            }
        }

        describe("valueChanged") {
            beforeEach {
                subject.viewDidLoad()
            }

            it("calls the delegate function when email is set") {
                let fake = FakeCredentialSettingsDelegate()
                subject.delegate = fake
                subject.emailView.textField.text = "email@example.com"
                subject.emailView.textField.sendActionsForControlEvents(.EditingChanged)
                expect(fake.didCall).to(beTrue())
            }

            it("calls the delegate function when username is set") {
                let fake = FakeCredentialSettingsDelegate()
                subject.delegate = fake
                subject.usernameView.textField.text = "username"
                subject.usernameView.textField.sendActionsForControlEvents(.EditingChanged)
                expect(fake.didCall).to(beTrue())
            }

            it("calls the delegate function when password is set") {
                let fake = FakeCredentialSettingsDelegate()
                subject.delegate = fake
                subject.passwordView.textField.text = "pa$$w0rd"
                subject.passwordView.textField.sendActionsForControlEvents(.EditingChanged)
                expect(fake.didCall).to(beTrue())
            }
        }

        describe("height") {
            beforeEach {
                let user: User = stub(["username": "TestName", "profile": Profile.stub(["email": "some@guy.com"])])
                subject.currentUser = user
                subject.viewDidLoad()
            }

            context("isUpdatable is true") {
                context("errorLabel is empty") {
                    it("returns 89 * 3 + 128") {
                        subject.passwordView.textField.text = "anything"
                        expect(subject.isUpdatable).to(beTrue())
                        expect(subject.height) == 89 * 3 + 128
                    }
                }

                context("errorLabel is not empty") {
                    it("returns 89 * 3 + 128 + errorLabel height + 8") {
                        subject.passwordView.textField.text = "anything"
                        subject.errorLabel.setLabelText("something")
                        subject.errorLabel.sizeToFit()
                        expect(subject.isUpdatable).to(beTrue())
                        expect(subject.height) == 89 * 3 + 128 + subject.errorLabel.frame.height + 8
                    }
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

class FakeCredentialSettingsDelegate: CredentialSettingsDelegate {
    var didCall = false

    func credentialSettingsDidUpdate() {
        didCall = true
    }
}
