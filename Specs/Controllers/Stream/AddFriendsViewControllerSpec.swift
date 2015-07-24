//
//  AddFriendsContainerViewControllerSpec.swift
//  Ello
//
//  Created by Sean on 2/26/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble


struct FakeAddressBook: ContactList {
    var localPeople: [LocalPerson] {
        return []
    }
}


class AddFriendsViewControllerSpec: QuickSpec {
    override func spec() {

        var subject = AddFriendsViewController(addressBook: FakeAddressBook())
        let webView = UIWebView(frame: CGRectMake(0, 0, 320, 640))
        subject.loadView()
        subject.viewDidLoad()

        describe("initialization") {

            it("is a BaseElloViewController") {
                expect(subject).to(beAKindOf(BaseElloViewController.self))
            }

            it("is a AddFriendsViewController") {
                expect(subject).to(beAKindOf(AddFriendsViewController.self))
            }

            it("has an invite service") {
                expect(subject.inviteService).toNot(beNil())
            }
        }

        describe("setContacts") {
            xit("sets the given array of contacts to the datasource") {
                let localPeople: [(LocalPerson, User?)] = [(LocalPerson(name: "name", emails: ["test@testing.com"], id: 123), .None)]

                subject.setContacts(localPeople)
                expect(subject.streamViewController.dataSource.streamCellItems.count).toEventually(equal(1))
                expect((subject.streamViewController.dataSource.visibleCellItems.first?.jsonable as! LocalPerson).name) == localPeople.first?.0.name
            }

            it("sets the internal list of contacts") {
                let localPeople: [(LocalPerson, User?)] = [(LocalPerson(name: "name", emails: ["test@testing.com"], id: 123), .None)]

                subject.setContacts(localPeople)
                expect(subject.allContacts.count) == 1
                expect(subject.allContacts.first?.0.name) == localPeople.first?.0.name
            }
        }

        xdescribe("filterFieldDidChange") {

            context("empty filter field") {
                it("sets the full list of contacts to the dataSource") {
                    let localPeople: [(LocalPerson, User?)] = [
                        (LocalPerson(name: "name", emails: ["test@testing.com"], id: 123), .None),
                        (LocalPerson(name: "that guy", emails: ["another@email.com"], id: 124), .None)
                    ]
                    subject.allContacts = localPeople
                    subject.searchFieldChanged("", isPostSearch: false)
                    expect(subject.streamViewController.dataSource.visibleCellItems.count) == 2
                }
            }

            context("non empty filter field") {
                context("name matching") {
                    it("sets the filtered list of contacts to the dataSource") {
                        let localPeople: [(LocalPerson, User?)] = [
                            (LocalPerson(name: "name", emails: ["test@testing.com"], id: 123), .None),
                            (LocalPerson(name: "that guy", emails: ["another@email.com"], id: 124), .None)
                        ]
                        subject.setContacts(localPeople)
                        subject.searchFieldChanged("at", isPostSearch: false)
                        expect(subject.streamViewController.dataSource.visibleCellItems.count) == 1
                        expect((subject.streamViewController.dataSource.visibleCellItems.first?.jsonable as! LocalPerson).name) == localPeople[1].0.name
                    }
                }

                context("email matching") {
                    it("sets the filtered list of contacts to the dataSource") {
                        let localPeople: [(LocalPerson, User?)] = [
                            (LocalPerson(name: "name", emails: ["test@testing.com"], id: 123), .None),
                            (LocalPerson(name: "that guy", emails: ["another@email.com"], id: 124), .None)
                        ]
                        subject.setContacts(localPeople)
                        subject.searchFieldChanged("test", isPostSearch: false)
                        expect(subject.streamViewController.dataSource.visibleCellItems.count) == 1
                        expect((subject.streamViewController.dataSource.visibleCellItems.first?.jsonable as! LocalPerson).name) == localPeople.first?.0.name
                    }
                }
            }
        }

    }
}
