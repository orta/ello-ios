//
//  AutoCompleteDataSourceSpec.swift
//  Ello
//
//  Created by Sean on 6/29/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble


class AutoCompleteDataSourceSpec: QuickSpec {
    override func spec() {
        describe("AutoCompleteDataSource") {

            var subject = AutoCompleteDataSource()

            beforeEach {
                subject = AutoCompleteDataSource()
            }

            describe("itemForIndexPath(_:)") {

                beforeEach {
                    let match = AutoCompleteMatch(type: AutoCompleteType.Username, range: Range<String.Index>(start: "test".startIndex, end: "test".endIndex), text: "test")
                    let item1 = AutoCompleteItem(result: AutoCompleteResult(name: "test"), type: AutoCompleteType.Username, match: match)
                    let item2 = AutoCompleteItem(result: AutoCompleteResult(name: "test"), type: AutoCompleteType.Emoji, match: match)
                    let item3 = AutoCompleteItem(result: AutoCompleteResult(name: "test"), type: AutoCompleteType.Username, match: match)
                    let item4 = AutoCompleteItem(result: AutoCompleteResult(name: "test"), type: AutoCompleteType.Username, match: match)

                    let items = [item1, item2, item3, item4]
                    subject.items = items
                }

                context("index path exists") {

                    it("returns correct item") {
                        expect(subject.itemForIndexPath(NSIndexPath(forRow: 1, inSection: 0))?.type) == AutoCompleteType.Emoji
                    }
                }

                context("index path does NOT exists") {

                    it("returns nil") {
                        expect(subject.itemForIndexPath(NSIndexPath(forRow: 100, inSection: 0))).to(beNil())
                    }
                }
            }

            context("UITableViewDataSource") {

                describe("tableView(_:numberOfrowsInSection:)") {

                    it("returns the correct count") {
                        let match = AutoCompleteMatch(type: AutoCompleteType.Username, range: Range<String.Index>(start: "test".startIndex, end: "test".endIndex), text: "test")
                        let item1 = AutoCompleteItem(result: AutoCompleteResult(name: "test"), type: AutoCompleteType.Username, match: match)
                        let item2 = AutoCompleteItem(result: AutoCompleteResult(name: "test"), type: AutoCompleteType.Username, match: match)
                        let item3 = AutoCompleteItem(result: AutoCompleteResult(name: "test"), type: AutoCompleteType.Username, match: match)
                        let item4 = AutoCompleteItem(result: AutoCompleteResult(name: "test"), type: AutoCompleteType.Username, match: match)

                        let items = [item1, item2, item3, item4]
                        subject.items = items

                        expect(subject.tableView(UITableView(frame: CGRectZero), numberOfRowsInSection: 0)) == 4
                    }
                }

                describe("tableView(_:cellForRowAtIndexPath:)") {

                    var vc = AutoCompleteViewController()

                    beforeEach {
                        vc = AutoCompleteViewController()
                        showController(vc)
                    }

                    it("returns an AutoCompleteCell") {
                        let match = AutoCompleteMatch(type: AutoCompleteType.Username, range: Range<String.Index>(start:"test".startIndex, end: "test".endIndex), text: "test")
                        let item1 = AutoCompleteItem(result: AutoCompleteResult(name: "test"), type: AutoCompleteType.Username, match: match)
                        let items = [item1]
                        vc.dataSource.items = items
                        vc.tableView.reloadData()

                        let expectedCell = vc.dataSource.tableView(vc.tableView, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))

                        expect(expectedCell).toNot(beNil())
                        expect(expectedCell).to(beAKindOf(AutoCompleteCell.self))
                    }
                }
            }
        }
    }
}
