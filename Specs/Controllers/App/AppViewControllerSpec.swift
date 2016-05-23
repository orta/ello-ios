//
//  AppViewControllerSpec.swift
//  Ello
//
//  Created by Sean Dougherty on 11/24/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

@testable import Ello
import Quick
import Nimble


class AppViewControllerSpec: QuickSpec {
    override func spec() {
        describe("AppViewController") {
            var subject: AppViewController!

            beforeEach {
                subject = AppViewController.instantiateFromStoryboard()
                let _ = subject.view
            }

            describe("initialization") {

                it("IBOutlets are  not nil") {
                    expect(subject.scrollView).notTo(beNil())
                    expect(subject.joinButton).notTo(beNil())
                    expect(subject.joinButton).notTo(beNil())
                }

                it("IBActions are wired up") {
                    let signInActions = subject.signInButton.actionsForTarget(subject, forControlEvent: UIControlEvents.TouchUpInside)
                    expect(signInActions).to(contain("signInTapped:"))
                    expect(signInActions?.count) == 1

                    let joinActions = subject.joinButton.actionsForTarget(subject, forControlEvent: UIControlEvents.TouchUpInside)
                    expect(joinActions).to(contain("joinTapped:"))
                    expect(joinActions?.count) == 1
                }

                it("IBActions are wired up") {
                    let signInActions = subject.signInButton.actionsForTarget(subject, forControlEvent: UIControlEvents.TouchUpInside)
                    expect(signInActions).to(contain("signInTapped:"))
                    expect(signInActions?.count) == 1

                    let joinActions = subject.joinButton.actionsForTarget(subject, forControlEvent: UIControlEvents.TouchUpInside)
                    expect(joinActions).to(contain("joinTapped:"))
                    expect(joinActions?.count) == 1

                }

                it("can be instantiated from storyboard") {
                    expect(subject).notTo(beNil())
                }

                it("is a BaseElloViewController") {
                    expect(subject).to(beAKindOf(BaseElloViewController.self))
                }

                it("is a AppViewController") {
                    expect(subject).to(beAKindOf(AppViewController.self))
                }
            }

            describe("starts with Ello branded screen") {

                it("has a hidden sign in button") {
                    expect(subject.signInButton.alpha) == 0.0
                }

                it("has a hidden sign up button") {
                    expect(subject.joinButton.alpha) == 0.0
                }
            }

            describe("navigateToDeeplink(:)") {

                let agent = SpecsTrackingAgent()

                beforeEach {
                    Tracker.sharedTracker.overrideAgent = agent
                }

                afterEach {
                    Tracker.sharedTracker.overrideAgent = nil
                }

                it("tracks deep link") {
                    subject.navigateToDeepLink("http://ello.co/deeplink")

                    expect(agent.lastEvent) == "Deep Link Visited"
                    expect(agent.lastProperties["path"] as? String) == "http://ello.co/deeplink"
                }
            }
            describe("snapshots") {
                beforeEach {
                    ElloProvider.sharedProvider = ElloProvider.ErrorStubbingProvider()
                }
                let subject = AppViewController.instantiateFromStoryboard()
                validateAllSnapshots(subject)
            }
        }
    }
}
