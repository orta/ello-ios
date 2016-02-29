//
//  SearchScreenSpec.swift
//  Ello
//
//  Created by Sean on 7/28/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Quick
import Nimble
import Ello
import Nimble_Snapshots

public class MockSearchScreenDelegate: NSObject, SearchScreenDelegate {
    var searchFieldWasCleared = false
    public func searchCanceled(){}
    public func searchFieldCleared(){searchFieldWasCleared = true}
    public func searchFieldChanged(text: String, isPostSearch: Bool){}
    public func searchFieldWillChange(){}
    public func toggleChanged(text: String, isPostSearch: Bool){}
    public func findFriendsTapped(){}
}

class SearchScreenSpec: QuickSpec {
    override func spec() {

        describe("SearchScreen") {
            var subject: SearchScreen!

            beforeEach {
                subject = SearchScreen(frame: CGRect(origin: .zero, size: CGSize(width: 320, height: 568)), isSearchView: true, navBarTitle: "Test", fieldPlaceholderText: "placeholder test")
            }

            context("hasBackButton") {
                it("has a back button by default") {
                    let prevItems = subject.navigationItem.leftBarButtonItems
                    expect(subject.hasBackButton) == true
                    expect(subject.navigationItem.leftBarButtonItem) == prevItems![0]

                    showView(subject)
                    expect(subject).to(haveValidSnapshot(named: "hasBackButton:true"))
                }

                it("can have a close button instead (left item changes)") {
                    let prevItems = subject.navigationItem.leftBarButtonItems
                    subject.hasBackButton = false
                    expect(subject.hasBackButton) == false
                    expect(subject.navigationItem.leftBarButtonItem) != prevItems![0]

                    showView(subject)
                    expect(subject).to(haveValidSnapshot(named: "hasBackButton:false"))
                }

                it("can have an explicit back button (left item changes)") {
                    var prevItems = subject.navigationItem.leftBarButtonItems
                    subject.hasBackButton = false
                    expect(subject.navigationItem.leftBarButtonItem) != prevItems![0]

                    prevItems = subject.navigationItem.leftBarButtonItems
                    subject.hasBackButton = true
                    expect(subject.hasBackButton) == true
                    expect(subject.navigationItem.leftBarButtonItem) != prevItems![0]

                    showView(subject)
                    expect(subject).to(haveValidSnapshot(named: "hasBackButton:true"))
                }
            }

            context("UITextFieldDelegate") {

                describe("textFieldShouldReturn(_:)") {

                    it("returns true") {
                        let shouldReturn = subject.textFieldShouldReturn(subject.searchField)

                        expect(shouldReturn) == true
                    }

                    it("hides keyboard") {
                        subject.textFieldShouldReturn(subject.searchField)

                        expect(subject.searchField.isFirstResponder()) == false
                    }
                }

                describe("textFieldShouldClear(_:)") {

                    it("returns true") {
                        let shouldReturn = subject.textFieldShouldClear(subject.searchField)

                        expect(shouldReturn) == true
                    }

                    it("calls search field cleared on it's delegate") {

                        let delegate = MockSearchScreenDelegate()
                        subject.delegate = delegate
                        subject.textFieldShouldClear(subject.searchField)

                        expect(delegate.searchFieldWasCleared) == true
                    }

                    context("is search view") {

                        beforeEach {
                            let isSearchView = true
                            subject = SearchScreen(frame: CGRectZero, isSearchView: isSearchView, navBarTitle: "Test", fieldPlaceholderText: "placeholder test")
                        }

                        it("hides find friends text") {
                            subject.textFieldShouldClear(subject.searchField)

                            expect(subject.findFriendsContainer.hidden) == false
                        }
                    }

                    context("is NOT search view") {

                        beforeEach {
                            let isSearchView = false
                            subject = SearchScreen(frame: CGRectZero, isSearchView: isSearchView, navBarTitle: "Test", fieldPlaceholderText: "placeholder test")
                        }

                        it("shows find friends text") {
                            subject.textFieldShouldClear(subject.searchField)

                            expect(subject.findFriendsContainer.hidden) == true
                        }
                    }
                }
            }
        }
    }
}

