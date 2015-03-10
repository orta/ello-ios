//
//  InviteFriendsViewControllerSpec.swift
//  Ello
//
//  Created by Sean on 2/26/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Quick
import Nimble


class InviteFriendsViewControllerSpec: QuickSpec {
    override func spec() {

        var subject = InviteFriendsViewController()

        beforeSuite {
            ElloProvider.sharedProvider = ElloProvider.StubbingProvider()
        }

        afterSuite {
            ElloProvider.sharedProvider = ElloProvider.DefaultProvider()
        }

        describe("initialization", {

            beforeEach({
                subject = InviteFriendsViewController()
            })

            describe("nib", {

                beforeEach({
                    subject.loadView()
                    subject.viewDidLoad()
                })

                it("IBOutlets are  not nil", {
                    expect(subject.tableView).notTo(beNil())
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

            it("is an InviteFriendsViewController", {
                expect(subject).to(beAKindOf(InviteFriendsViewController.self))
            })

            it("has an invite service") {
                expect(subject.inviteService).toNot(beNil())
            }
        })

        describe("-viewDidLoad:", {

            beforeEach({
                subject = InviteFriendsViewController()
                subject.loadView()
                subject.viewDidLoad()
            })

            it("configures dataSource") {
                expect(subject.dataSource).to(beAnInstanceOf(AddFriendsDataSource.self))
            }

            it("configures tableView") {
                let delegate = subject.tableView.delegate! as InviteFriendsViewController
                expect(delegate) == subject

                let dataSource = subject.tableView.dataSource! as AddFriendsDataSource
                expect(dataSource) == subject.dataSource
            }
            
        })

        describe("setContacts") {
            it("sets the given array of contacts to the datasource") {
                let localPeople: [(LocalPerson, User?)] = [(LocalPerson(name: "name", emails: ["test@testing.com"], id: 123), .None)]

                subject.setContacts(localPeople)
                expect(subject.dataSource.items.count) == 1
                expect(subject.dataSource.items.first?.person?.name) == localPeople.first?.0.name
            }
        }
    }
}