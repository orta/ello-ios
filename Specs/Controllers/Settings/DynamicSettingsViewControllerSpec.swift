//
//  DynamicSettingsViewControllerSpec.swift
//  Ello
//
//  Created by Colin Gray on 5/3/2016.
//  Copyright (c) 2016 Ello. All rights reserved.
//

@testable import Ello
import Quick
import Nimble


class DynamicSettingsViewControllerSpec: QuickSpec {
    override func spec() {
        describe("DynamicSettingsViewController") {
            context("changing mutedCount and blockedCount") {
                var subject: DynamicSettingsViewController!

                beforeEach {
                    subject = UIStoryboard.storyboardWithId(.DynamicSettings, storyboardName: "Settings") as! DynamicSettingsViewController
                }
                describe("when mutedCount is 0") {
                    beforeEach {
                        let currentProfile: Profile = stub(["mutedCount": 0, "blockedCount": 0])
                        let currentUser: User = stub(["profile": currentProfile])
                        subject.currentUser = currentUser
                        showController(subject)
                    }
                    it("should have correct number of sections") {
                        subject.numberOfSectionsInTableView(subject.tableView) == 4
                    }
                    it("should have correct number of rows (0) for blocked section") {
                        subject.tableView(subject.tableView, numberOfRowsInSection: 1) == 0
                    }
                    it("should have correct number of rows (0) for muted section") {
                        subject.tableView(subject.tableView, numberOfRowsInSection: 2) == 0
                    }
                }
                describe("when mutedCount is 1") {
                    beforeEach {
                        let currentProfile: Profile = stub(["mutedCount": 1, "blockedCount": 0])
                        let currentUser: User = stub(["profile": currentProfile])
                        subject.currentUser = currentUser
                        showController(subject)
                    }
                    it("should have correct number of sections") {
                        subject.numberOfSectionsInTableView(subject.tableView) == 4
                    }
                    it("should have correct number of rows (0) for blocked section") {
                        subject.tableView(subject.tableView, numberOfRowsInSection: 1) == 0
                    }
                    it("should have correct number of rows (1) for muted section") {
                        subject.tableView(subject.tableView, numberOfRowsInSection: 2) == 1
                    }
                }
                describe("when mutedCount changes from 1 to 0") {
                    beforeEach {
                        let currentProfile: Profile = stub(["mutedCount": 1, "blockedCount": 0])
                        let currentUser: User = stub(["profile": currentProfile])
                        subject.currentUser = currentUser
                        showController(subject)
                        postNotification(MutedCountChangedNotification, value: ("", -1))
                    }
                    it("should have correct number of sections") {
                        subject.numberOfSectionsInTableView(subject.tableView) == 4
                    }
                    it("should have correct number of rows (0) for blocked section") {
                        subject.tableView(subject.tableView, numberOfRowsInSection: 1) == 0
                    }
                    it("should have correct number of rows (0) for muted section") {
                        subject.tableView(subject.tableView, numberOfRowsInSection: 2) == 0
                    }
                }
                describe("when blockedCount is 0") {
                    beforeEach {
                        let currentProfile: Profile = stub(["mutedCount": 0, "blockedCount": 0])
                        let currentUser: User = stub(["profile": currentProfile])
                        subject.currentUser = currentUser
                        showController(subject)
                    }
                    it("should have correct number of sections") {
                        subject.numberOfSectionsInTableView(subject.tableView) == 4
                    }
                    it("should have correct number of rows (0) for blocked section") {
                        subject.tableView(subject.tableView, numberOfRowsInSection: 1) == 0
                    }
                    it("should have correct number of rows (0) for muted section") {
                        subject.tableView(subject.tableView, numberOfRowsInSection: 2) == 0
                    }
                }
                describe("when blockedCount is 1") {
                    beforeEach {
                        let currentProfile: Profile = stub(["mutedCount": 0, "blockedCount": 1])
                        let currentUser: User = stub(["profile": currentProfile])
                        subject.currentUser = currentUser
                        showController(subject)
                    }
                    it("should have correct number of sections") {
                        subject.numberOfSectionsInTableView(subject.tableView) == 4
                    }
                    it("should have correct number of rows (1) for blocked section") {
                        subject.tableView(subject.tableView, numberOfRowsInSection: 1) == 1
                    }
                    it("should have correct number of rows (0) for muted section") {
                        subject.tableView(subject.tableView, numberOfRowsInSection: 2) == 0
                    }
                }
                describe("when blockedCount changes from 1 to 0") {
                    beforeEach {
                        let currentProfile: Profile = stub(["mutedCount": 0, "blockedCount": 1])
                        let currentUser: User = stub(["profile": currentProfile])
                        subject.currentUser = currentUser
                        showController(subject)
                        postNotification(BlockedCountChangedNotification, value: ("", -1))
                    }
                    it("should have correct number of sections") {
                        subject.numberOfSectionsInTableView(subject.tableView) == 4
                    }
                    it("should have correct number of rows (0) for blocked section") {
                        subject.tableView(subject.tableView, numberOfRowsInSection: 1) == 0
                    }
                    it("should have correct number of rows (0) for muted section") {
                        subject.tableView(subject.tableView, numberOfRowsInSection: 2) == 0
                    }
                }
            }
        }
    }
}
