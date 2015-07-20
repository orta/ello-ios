//
//  AutoCompleteViewControllerSpec.swift
//  Ello
//
//  Created by Sean on 6/29/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble


class AutoCompleteViewControllerSpec: QuickSpec {
    override func spec() {
        describe("AutoCompleteViewController") {
            describe("nib") {

                var subject = AutoCompleteViewController()

                beforeEach {
                    subject = AutoCompleteViewController()
                    subject.loadView()
                }

                it("IBOutlets are not nil") {
                    expect(subject.tableView).toNot(beNil())
                }

                it("sets up the tableView's delegate and dataSource") {
                    subject.viewDidLoad()
                    subject.viewWillAppear(false)
                    let delegate = subject.tableView.delegate! as! AutoCompleteViewController
                    let dataSource = subject.tableView.dataSource! as! AutoCompleteDataSource

                    expect(delegate).to(equal(subject))
                    expect(dataSource).to(equal(subject.dataSource))
                }
            }

            describe("viewDidLoad()") {

                var subject = AutoCompleteViewController()

                beforeEach {
                    subject = AutoCompleteViewController()
                    self.showController(subject)
                    subject.loadView()
                    subject.viewDidLoad()
                }

                it("styles the view") {
                    expect(subject.tableView.backgroundColor) == UIColor.blackColor()
                }

                it("registers cells") {
                    subject.viewWillAppear(false)
                    subject.dataSource.items = [AutoCompleteItem(result: AutoCompleteResult(), type: AutoCompleteType.Emoji)]

                    expect(subject.tableView).to(haveRegisteredIdentifier(AutoCompleteCell.reuseIdentifier()))
                }
            }
        }
    }
}
