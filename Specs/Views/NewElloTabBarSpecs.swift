//
//  NewElloTabBarSpecs.swift
//  Ello
//
//  Created by Colin Gray on 11/2/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

@testable import Ello
import Quick
import Nimble
import Nimble_Snapshots


class NewElloTabBarSpecs: QuickSpec {
    override func spec() {
        fdescribe("NewElloTabBar.ItemView") {
            let tests: [String: NewElloTabBar.Item] = [
                "should support a selected? title": NewElloTabBar.Item(alignment: .Left, display: .Title(InterfaceString.Following.Title.localized), redDotHidden: true),
                "should support a selected? title with a red dot": NewElloTabBar.Item(alignment: .Left, display: .Title(InterfaceString.Following.Title.localized), redDotHidden: false),
                "should support a selected? svg": NewElloTabBar.Item(alignment: .Left, display: .SVG("bolt"), redDotHidden: true),
                "should support a selected? svg with a red dot": NewElloTabBar.Item(alignment: .Left, display: .SVG("bolt"), redDotHidden: false),
            ]
            for (description, item) in tests {
                let unselectedDescription = description.stringByReplacingOccurrencesOfString("selected? ", withString: "")
                let selectedDescription = description.stringByReplacingOccurrencesOfString("selected? ", withString: "selected ")
                it(unselectedDescription) {
                    let subject = NewElloTabBar.ItemView(item: item)
                    subject.frame = CGRect(origin: CGPointZero, size: subject.intrinsicContentSize())
                    subject.selected = false
                    expect(subject).to(haveValidSnapshot())
                }
                it(selectedDescription) {
                    let subject = NewElloTabBar.ItemView(item: item)
                    subject.frame = CGRect(origin: CGPointZero, size: subject.intrinsicContentSize())
                    subject.selected = true
                    expect(subject).to(haveValidSnapshot())
                }
            }
        }
        fdescribe("NewElloTabBar") {
            it("should accept empty NewElloTabBar.Items") {
                let subject = NewElloTabBar()
                let items: [NewElloTabBar.Item] = []
                subject.items = items
                expect(subject.items.count) == 0
            }
            it("should accept some NewElloTabBar.Items") {
                let subject = NewElloTabBar()
                subject.items = [
                    NewElloTabBar.Item(alignment: .Left, display: .Title(InterfaceString.Following.Title.localized), redDotHidden: true),
                    NewElloTabBar.Item(alignment: .Right, display: .SVG("bolt"), redDotHidden: false),
                ]

                expect(subject.items.count) == 2
                expect(subject.items[0].title) == InterfaceString.Following.Title.localized
                expect(subject.items[1].svg) == "bolt"
            }
            describe("snapshots") {
                var subject: NewElloTabBar!

                beforeEach {
                    subject = NewElloTabBar()
                    subject.items = [
                        NewElloTabBar.Item(alignment: .Left, display: .Title(InterfaceString.Following.Title.localized), redDotHidden: true),
                        NewElloTabBar.Item(alignment: .Left, display: .Title(InterfaceString.Starred.Title.localized), redDotHidden: false),
                        NewElloTabBar.Item(alignment: .Left, display: .Title(InterfaceString.Discover.Title.localized), redDotHidden: true),
                        NewElloTabBar.Item(alignment: .Right, display: .SVG("bolt"), redDotHidden: false),
                        NewElloTabBar.Item(alignment: .Right, display: .SVG("search"), redDotHidden: true),
                    ]
                }
                let tests: [String: CGSize] = [
                    "should be valid for iphone 4": CGSize(width: 320, height: 50),
                    "should be valid for iphone 4.7": CGSize(width: 375, height: 50),
                    "should be valid for iphone 5.5": CGSize(width: 414, height: 50),
                    "should be valid for ipad portrait": CGSize(width: 768, height: 50),
                    "should be valid for ipad landscape": CGSize(width: 1024, height: 50),
                ]
                for (description, size) in tests {
                    it(description) {
                        subject.frame.size = size
                        expect(subject).to(haveValidSnapshot())
                    }

                    let selections: [String: Int] = [
                        "following": 0,
                        "starred": 1,
                        "notifications": 2,
                        "search": 3,
                    ]
                    for (name, index) in selections {
                        it("\(description) selecting \(name)") {
                            subject.frame.size = size
                            subject.selectedIndex = index
                            expect(subject).to(haveValidSnapshot())
                        }
                    }
                }
            }
        }
    }
}
