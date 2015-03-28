//
//  AddFriendsContainerViewControllerSpec.swift
//  Ello
//
//  Created by Sean on 2/26/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Quick
import Nimble

struct FakeAddressBook: ContactList {
    var localPeople: [LocalPerson] {
        return []
    }
}


class AddFriendsContainerViewControllerSpec: QuickSpec {
    override func spec() {

        var subject = AddFriendsContainerViewController(addressBook: FakeAddressBook())

        beforeSuite {
            ElloProvider.sharedProvider = ElloProvider.StubbingProvider()
        }

        afterSuite {
            ElloProvider.sharedProvider = ElloProvider.DefaultProvider()
        }

        describe("initialization") {

            beforeEach {
                subject = AddFriendsContainerViewController(addressBook: FakeAddressBook())
            }

            describe("nib") {

                beforeEach {
                    subject.loadView()
                    subject.viewDidLoad()
                }

                it("IBOutlets are  not nil") {
                    expect(subject.pageView).notTo(beNil())
                    expect(subject.navigationBar).notTo(beNil())
                    expect(subject.navigationBarTopConstraint).notTo(beNil())
                    expect(subject.inviteButton).notTo(beNil())
                    expect(subject.findButton).notTo(beNil())
                }

                it("IBActions are wired up") {
                    let inviteActions = subject.inviteButton.actionsForTarget(subject, forControlEvent: UIControlEvents.TouchUpInside)

                    expect(inviteActions).to(contain("inviteFriendsTapped:"))

                    expect(inviteActions?.count) == 1

                    let findActions = subject.findButton.actionsForTarget(subject, forControlEvent: UIControlEvents.TouchUpInside)

                    expect(findActions).to(contain("findFriendsTapped:"))

                    expect(findActions?.count) == 1
                }
            }

            it("can be instantiated from nib") {
                expect(subject).notTo(beNil())
            }

            it("is a BaseElloViewController") {
                expect(subject).to(beAKindOf(BaseElloViewController.self))
            }

            it("is a AddFriendsContainerViewController") {
                expect(subject).to(beAKindOf(AddFriendsContainerViewController.self))
            }

            it("properly configures a UIPageViewController") {
                expect(subject.pageViewController.transitionStyle) == UIPageViewControllerTransitionStyle.Scroll
                expect(subject.pageViewController.navigationOrientation) == UIPageViewControllerNavigationOrientation.Horizontal
            }

            it("creates a FindFriendsViewController") {
                expect(subject.findFriendsViewController).to(beAKindOf(FindFriendsViewController.self))
            }

            it("creates a InviteFriendsViewController") {
                expect(subject.inviteFriendsViewController).to(beAKindOf(InviteFriendsViewController.self))
            }
        }

        describe("-viewDidLoad:") {

            beforeEach {
                subject = AddFriendsContainerViewController(addressBook: FakeAddressBook())
                subject.loadView()
                subject.viewDidLoad()
            }

            it("configures buttons") {
                expect(subject.findButton.selected).to(beTrue())
                expect(subject.inviteButton.selected).to(beFalse())
            }
        }
    }
}
