//
//  FindFriendsViewControllerSpec.swift
//  Ello
//
//  Created by Sean on 2/26/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Quick
import Nimble


class FindFriendsViewControllerSpec: QuickSpec {
    override func spec() {

        var subject = FindFriendsViewController()

        beforeSuite {
            ElloProvider.sharedProvider = ElloProvider.StubbingProvider()
        }

        afterSuite {
            ElloProvider.sharedProvider = ElloProvider.DefaultProvider()
        }

        describe("initialization") {

            beforeEach {
                subject = FindFriendsViewController()
            }

            describe("nib") {

                beforeEach({
                    subject.loadView()
                    subject.viewDidLoad()
                })

                it("IBOutlets are  not nil", {
                    expect(subject.tableView).notTo(beNil())
                })

                it("IBActions are wired up", {

                });
            }

            it("can be instantiated from nib") {
                expect(subject).notTo(beNil())
            }

            it("is a BaseElloViewController") {
                expect(subject).to(beAKindOf(BaseElloViewController.self))
            }

            it("is a FindFriendsViewController") {
                expect(subject).to(beAKindOf(FindFriendsViewController.self))
            }

            it("has an invite service") {
                expect(subject.inviteService).toNot(beNil())
            }
        }

        describe("-viewDidLoad:") {

            beforeEach {
                subject = FindFriendsViewController()
                subject.loadView()
                subject.viewDidLoad()
            }

            it("configures dataSource") {
                expect(subject.dataSource).to(beAnInstanceOf(AddFriendsDataSource.self))
            }

            it("configures tableView") {
                let delegate = subject.tableView.delegate! as FindFriendsViewController
                expect(delegate) == subject

                let dataSource = subject.tableView.dataSource! as AddFriendsDataSource
                expect(dataSource) == subject.dataSource
            }
        }

        describe("setUsers") {
            it("should set the given array of users to the datasource") {
                let data = stubbedJSONData("user", "users")
                let user = User.fromJSON(data) as User

                subject.setUsers([user])
                expect(subject.dataSource.items.count) == 1
                expect(subject.dataSource.items.first?.user) == user
            }
        }
    }
}
