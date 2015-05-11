//
//  SignInViewControllerSpec.swift
//  Ello
//
//  Created by Sean Dougherty on 11/24/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble


class SignInViewControllerSpec: QuickSpec {
    override func spec() {

        var subject = SignInViewController()
        let screenHeight = subject.view.bounds.size.height
        let screenWidth = subject.view.bounds.size.width

        beforeEach {
            subject = SignInViewController()
            subject.loadView()
            subject.viewDidLoad()
        }

        describe("initialization") {

            describe("nib") {

                it("IBOutlets are  not nil") {
                    expect(subject.scrollView).notTo(beNil())
                    expect(subject.enterButton).notTo(beNil())
                    expect(subject.forgotPasswordButton).notTo(beNil())
                    expect(subject.emailTextField).notTo(beNil())
                    expect(subject.passwordTextField).notTo(beNil())
                    expect(subject.joinButton).notTo(beNil())
                    expect(subject.enterButtonTopContraint).notTo(beNil())
                    expect(subject.errorLabel).notTo(beNil())
                    expect(subject.elloLogo).notTo(beNil())
                    expect(subject.onePasswordButton).notTo(beNil())
                }

                it("IBActions are wired up") {
                    let enterActions = subject.enterButton.actionsForTarget(subject, forControlEvent: UIControlEvents.TouchUpInside)
                    expect(enterActions).to(contain("enterTapped:"))
                    expect(enterActions?.count) == 1

                    let forgotPasswordActions = subject.forgotPasswordButton.actionsForTarget(subject, forControlEvent: UIControlEvents.TouchUpInside)
                    expect(forgotPasswordActions).to(contain("forgotPasswordTapped:"))
                    expect(forgotPasswordActions?.count) == 1

                    let joinActions = subject.joinButton.actionsForTarget(subject, forControlEvent: UIControlEvents.TouchUpInside)
                    expect(joinActions).to(contain("joinTapped:"))
                    expect(joinActions?.count) == 1

                    let onePasswordActions = subject.onePasswordButton.actionsForTarget(subject, forControlEvent: UIControlEvents.TouchUpInside)
                    expect(onePasswordActions).to(contain("findLoginFrom1Password:"))
                    expect(onePasswordActions?.count) == 1
                }
            }

            it("can be instantiated from nib") {
                expect(subject).notTo(beNil())
            }

            it("is a BaseElloViewController") {
                expect(subject).to(beAKindOf(BaseElloViewController.self))
            }

            it("is a SignInViewController") {
                expect(subject).to(beAKindOf(SignInViewController.self))
            }
        }

        describe("text fields") {

            context("emailTextField") {

                it("is properly configured") {
                    expect(subject.emailTextField.keyboardType.rawValue) == UIKeyboardType.EmailAddress.rawValue
                    expect(subject.emailTextField.returnKeyType.rawValue) == UIReturnKeyType.Next.rawValue
                }

                it("has controller as delegate") {
                    expect(subject.emailTextField.delegate) === subject
                }

            }

            context("passwordTextField") {

                it("is properly configured") {
                    expect(subject.passwordTextField.keyboardType.rawValue) == UIKeyboardType.Default.rawValue
                    expect(subject.passwordTextField.returnKeyType.rawValue) == UIReturnKeyType.Go.rawValue
                    expect(subject.passwordTextField.secureTextEntry) == true
                }

                it("has controller as delegate") {
                    expect(subject.passwordTextField.delegate) === subject
                }
            }
        }

        describe("-viewDidLoad") {

            it("has a cross dissolve modal transition style") {
                expect(subject.modalTransitionStyle.rawValue) == UIModalTransitionStyle.CrossDissolve.rawValue
            }

            it("has a disabled enter button") {
                expect(subject.enterButton.enabled) == false
            }
        }

        describe("IBActions") {
            describe("enterTapped") {

                it("dismisses the keyboard") {
                    subject.emailTextField.becomeFirstResponder()
                    subject.enterTapped(subject.enterButton)
                    expect(subject.emailTextField.isFirstResponder()) == false


                    subject.passwordTextField.becomeFirstResponder()
                    subject.enterTapped(subject.enterButton)
                    expect(subject.passwordTextField.isFirstResponder()) == false
                }

                context("input is valid") {

                    it("disables input") {
                        subject.emailTextField.text = "name@example.com"
                        subject.passwordTextField.text = "12345678"

                        subject.enterTapped(subject.enterButton)
                        expect(subject.emailTextField.enabled) == false
                        expect(subject.passwordTextField.enabled) == false
                        expect(subject.enterButton.enabled) == false
                        expect(subject.view.userInteractionEnabled) == false
                    }

                }

                context("input is invalid") {

                    it("does not disable input") {
                        subject.emailTextField.text = "invalid email"
                        subject.passwordTextField.text = "abc"

                        subject.enterTapped(subject.enterButton)
                        expect(subject.emailTextField.enabled) == true
                        expect(subject.passwordTextField.enabled) == true
                        expect(subject.enterButton.enabled) == false
                        expect(subject.view.userInteractionEnabled) == true
                    }
                }
            }
        }

        describe("notifications") {

            describe("UIKeyboardWillShowNotification") {

                context("keyboard is docked") {

                    it("adjusts scrollview") {
                        Keyboard.shared().topEdge = screenHeight - 303.0
                        postNotification(Keyboard.Notifications.KeyboardWillShow, Keyboard.shared())

                        expect(subject.scrollView.contentInset.bottom) > 50
                    }
                }

                context("keyboard is not docked") {
                    xit("does NOT adjust scrollview") {
                        // this is not easily faked with Keyboard unfortunately
                        Keyboard.shared().topEdge = screenHeight - 100.0
                        postNotification(Keyboard.Notifications.KeyboardWillShow, Keyboard.shared())

                        expect(subject.scrollView.contentInset.bottom) == 0
                    }
                }
            }

            describe("UIKeyboardWillHideNotification") {

                it("adjusts scrollview") {
                    Keyboard.shared().topEdge = 0.0
                    postNotification(Keyboard.Notifications.KeyboardWillHide, Keyboard.shared())

                    expect(subject.scrollView.contentInset.bottom) == 0.0
                }
            }
        }
    }
}

