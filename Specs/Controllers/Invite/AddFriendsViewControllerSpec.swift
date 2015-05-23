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
        subject.loadView()
        subject.viewDidLoad()

        describe("initialization") {

            describe("nib") {

                it("IBOutlets are  not nil") {
                    expect(subject.tableView).notTo(beNil())
                    expect(subject.filterField).notTo(beNil())
                    expect(subject.navigationBar).notTo(beNil())
                    expect(subject.navigationBarTopConstraint).notTo(beNil())
                }

                it("IBActions are wired up") {
                    let filterActions = subject.filterField.actionsForTarget(subject, forControlEvent: UIControlEvents.EditingChanged)
                    expect(filterActions).to(contain("filterFieldDidChange:"))
                    expect(filterActions?.count) == 1
                }
            }

            it("can be instantiated from nib") {
                expect(subject).notTo(beNil())
            }

            it("is a BaseElloViewController") {
                expect(subject).to(beAKindOf(BaseElloViewController.self))
            }

            it("is a AddFriendsViewController") {
                expect(subject).to(beAKindOf(AddFriendsViewController.self))
            }

            it("has an invite service") {
                expect(subject.inviteService).toNot(beNil())
            }

            it("has a data source") {
                expect(subject.dataSource).toNot(beNil())
            }
        }

        describe("-viewDidLoad:") {

            it("configures dataSource") {
                expect(subject.dataSource).to(beAnInstanceOf(AddFriendsDataSource.self))
            }

            it("configures tableView") {
                let delegate = subject.tableView.delegate! as! AddFriendsViewController
                expect(delegate) == subject

                let dataSource = subject.tableView.dataSource! as! AddFriendsDataSource
                expect(dataSource) == subject.dataSource
            }
        }

        describe("setContacts") {
            it("sets the given array of contacts to the datasource") {
                let localPeople: [(LocalPerson, User?)] = [(LocalPerson(name: "name", emails: ["test@testing.com"], id: 123), .None)]

                subject.setContacts(localPeople)
                expect(subject.dataSource.items.count) == 1
                expect(subject.dataSource.items.first?.person?.name) == localPeople.first?.0.name
            }

            it("sets the internal list of contacts") {
                let localPeople: [(LocalPerson, User?)] = [(LocalPerson(name: "name", emails: ["test@testing.com"], id: 123), .None)]

                subject.setContacts(localPeople)
                expect(subject.allContacts.count) == 1
                expect(subject.allContacts.first?.0.name) == localPeople.first?.0.name
            }
        }

        describe("filterFieldDidChange") {

            context("empty filter field") {
                it("sets the full list of contacts to the dataSource") {
                    let localPeople: [(LocalPerson, User?)] = [
                        (LocalPerson(name: "name", emails: ["test@testing.com"], id: 123), .None),
                        (LocalPerson(name: "that guy", emails: ["another@email.com"], id: 124), .None)
                    ]
                    subject.allContacts = localPeople
                    let filterText = UITextField()
                    filterText.text = ""
                    subject.filterFieldDidChange(filterText)
                    expect(subject.dataSource.items.count) == 2
                }
            }

            context("non empty filter field") {
                context("name matching") {
                    it("sets the filtered list of contacts to the dataSource") {
                        let localPeople: [(LocalPerson, User?)] = [
                            (LocalPerson(name: "name", emails: ["test@testing.com"], id: 123), .None),
                            (LocalPerson(name: "that guy", emails: ["another@email.com"], id: 124), .None)
                        ]
                        subject.allContacts = localPeople
                        let filterText = UITextField()
                        filterText.text = "at"
                        subject.filterFieldDidChange(filterText)
                        expect(subject.dataSource.items.count) == 1
                        expect(subject.dataSource.items.first?.person?.name) == localPeople[1].0.name
                    }
                }

                context("email matching") {
                    it("sets the filtered list of contacts to the dataSource") {
                        let localPeople: [(LocalPerson, User?)] = [
                            (LocalPerson(name: "name", emails: ["test@testing.com"], id: 123), .None),
                            (LocalPerson(name: "that guy", emails: ["another@email.com"], id: 124), .None)
                        ]
                        subject.allContacts = localPeople
                        let filterText = UITextField()
                        filterText.text = "test"
                        subject.filterFieldDidChange(filterText)
                        expect(subject.dataSource.items.count) == 1
                        expect(subject.dataSource.items.first?.person?.name) == localPeople.first?.0.name
                    }
                }
            }
        }

        context("protocol conformance") {

            context("UITableViewDelegate") {

                it("is a UITableViewDelegate") {
                    expect(subject as UITableViewDelegate).notTo(beNil())
                }

                describe("-tableView:heightForRowAtIndexPath:") {

                    it("returns 60") {
                        let height = subject.tableView(subject.tableView, heightForRowAtIndexPath:NSIndexPath(forRow: 0, inSection: 0))

                        expect(height) == 60
                    }
                }

            }

            context("UIScrollViewDelegate") {
                
                it("is a UIScrollViewDelegate") {
                    expect(subject as UIScrollViewDelegate).notTo(beNil())
                }
            }
        }

    }
}
