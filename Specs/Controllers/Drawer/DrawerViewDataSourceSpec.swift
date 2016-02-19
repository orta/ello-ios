//
//  DrawerViewDataSourceSpec.swift
//  Ello
//
//  Created by Gordon Fontenot on 3/16/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

@testable import Ello
import Quick
import Nimble


class DrawerViewDataSourceSpec: QuickSpec {
    override func spec() {

        context("UITableViewDataSource") {

            describe("tableView(_:numberOfrowsInSection:)") {

                it("returns 7") {
                    let dataSource = DrawerViewDataSource()
                    expect(dataSource.tableView(UITableView(frame: CGRectZero), numberOfRowsInSection: 0)) == 7
                }
            }

            describe("itemForIndexPath(:)") {

                describe("has the correct items") {
                    let expectations: [DrawerItem] = [
                        DrawerItem(name: InterfaceString.Drawer.Store, type: .External("http://ello.threadless.com/")),
                        DrawerItem(name: InterfaceString.Drawer.Invite, type: .Invite),
                        DrawerItem(name: InterfaceString.Drawer.Help, type: .External("https://ello.co/wtf/help/the-basics/")),
                        DrawerItem(name: InterfaceString.Drawer.Resources, type: .External("https://ello.co/wtf/resources/community-directory/")),
                        DrawerItem(name: InterfaceString.Drawer.About, type: .External("https://ello.co/wtf/about/what-is-ello/")),
                        DrawerItem(name: InterfaceString.Drawer.Logout, type: .Logout),
                        DrawerItem(name: InterfaceString.Drawer.Version, type: .Version),
                    ]
                    let dataSource = DrawerViewDataSource()
                    for (row, expectation) in expectations.enumerate() {
                        it("should have the correct item at index \(row)") {
                            let item = dataSource.itemForIndexPath(NSIndexPath(forRow: row, inSection: 0))
                            if let item = item {
                                expect(item.name) == expectation.name
                                expect("\(item.type)") == "\(expectation.type)"
                            }
                            else {
                                fail("no item at index \(row)")
                            }
                        }
                    }
                }
            }
        }
    }
}
