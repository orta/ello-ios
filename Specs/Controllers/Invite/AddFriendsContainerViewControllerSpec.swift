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

        describe("initialization", {

            beforeEach({
                subject = AddFriendsContainerViewController(addressBook: FakeAddressBook())
            })

            describe("nib", {

                beforeEach({
                    subject.loadView()
                    subject.viewDidLoad()
                })

                it("IBOutlets are  not nil", {
                    expect(subject.pageView).notTo(beNil())
                    expect(subject.segmentedControl).notTo(beNil())
                })

                it("IBActions are wired up", {

                });
            })

            it("can be instantiated from nib") {
                expect(subject).notTo(beNil())
            }

            it("is a BaseElloViewController", {
                expect(subject).to(beAKindOf(BaseElloViewController.self))
            })

            it("is a AddFriendsContainerViewController", {
                expect(subject).to(beAKindOf(AddFriendsContainerViewController.self))
            })

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
        })

        describe("-viewDidLoad:", {

            beforeEach({
                subject = AddFriendsContainerViewController(addressBook: FakeAddressBook())
                subject.loadView()
                subject.viewDidLoad()
            })

//            it("configures dataSource") {
//                expect(subject.dataSource).to(beAnInstanceOf(AddFriendsDataSource.self))
//            }
//
//            it("configures tableView") {
//                let delegate = subject.tableView.delegate! as InviteFriendsViewController
//                expect(delegate) == subject
//                
//                let dataSource = subject.tableView.dataSource! as AddFriendsDataSource
//                expect(dataSource) == subject.dataSource
//            }
//            
        })
    }
}