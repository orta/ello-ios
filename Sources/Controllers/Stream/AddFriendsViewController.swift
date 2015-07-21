//
//  AddFriendsViewController.swift
//  Ello
//
//  Created by Ryan Boyajian on 5/22/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit

public class AddFriendsViewController: StreamableViewController {

    let addressBook: ContactList

    public let inviteService = InviteService()
    public var allContacts: [(LocalPerson, User?)] = []
    public var userTappedDelegate: UserTappedDelegate?

    var _mockScreen: SearchScreenProtocol?
    public var screen: SearchScreenProtocol {
        set(screen) { _mockScreen = screen }
        get { return _mockScreen ?? self.view as! SearchScreen }
    }
    public var searchScreen: SearchScreen!

    required public init(addressBook: ContactList) {
        self.addressBook = addressBook
        super.init(nibName: nil, bundle: nil)
        streamViewController.initialLoadClosure = findFriendsFromContacts
        streamViewController.pullToRefreshEnabled = false
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func loadView() {
        searchScreen = SearchScreen(frame: UIScreen.mainScreen().bounds,
            navBarTitle: NSLocalizedString("Find & invite your friends", comment: "Find Friends"),
            fieldPlaceholderText: NSLocalizedString("Name or email", comment: "Find placeholder text"),
            addFindFriendsButton: false)
        self.view = searchScreen
        searchScreen.delegate = self
    }

    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if isMovingToParentViewController() {
            showNavBars(false)
            updateInsets()
            ElloHUD.showLoadingHudInView(streamViewController.view)
            streamViewController.loadInitialPage()
        }
    }

    override func viewForStream() -> UIView {
        return screen.viewForStream()
    }

    override func showNavBars(scrollToBottom : Bool) {
    }

    override func hideNavBars() {
    }

    private func updateInsets() {
        streamViewController.contentInset.bottom = ElloTabBar.Size.height
        screen.updateInsets(bottom: ElloTabBar.Size.height)
    }

    public func setContacts(contacts: [(LocalPerson, User?)]) {
        allContacts = contacts
        var foundItems = [StreamCellItem]()
        var inviteItems = [StreamCellItem]()
        for contact in allContacts {
            var (person: LocalPerson, user: User?) = contact
            if user != nil {
                foundItems.append(StreamCellItem(jsonable: user!, type: StreamCellType.UserListItem, data: nil, oneColumnCellHeight: 56.0, multiColumnCellHeight: 56.0, isFullWidth: true))
            }
            else {
                if let currentUser = currentUser, let profile = currentUser.profile {
                    if !contains(person.emails, profile.email) {
                        inviteItems.append(StreamCellItem(jsonable: person, type: StreamCellType.InviteFriends, data: nil, oneColumnCellHeight: 56.0, multiColumnCellHeight: 56.0, isFullWidth: true))
                    }

                }
            }
        }
        foundItems.sort { ($0.jsonable as! User).username.lowercaseString < ($1.jsonable as! User).username.lowercaseString }
        inviteItems.sort { ($0.jsonable as! LocalPerson).name.lowercaseString < ($1.jsonable as! LocalPerson).name.lowercaseString }
        // this calls doneLoading when cells are added
        streamViewController.appendUnsizedCellItems(foundItems + inviteItems, withWidth: self.view.frame.width)
    }

    // MARK: - Private

    private func findFriendsFromContacts() {
        let localToken = streamViewController.resetInitialPageLoadingToken()

        var contacts = [String: [String]]()
        for person in addressBook.localPeople {
            contacts[person.identifier] = person.emails
        }
        InviteService().find(contacts,
            currentUser: self.currentUser,
            success: { users in
                if !self.streamViewController.isValidInitialPageLoadingToken(localToken) { return }

                self.streamViewController.clearForInitialLoad()
                let userIdentifiers = users.map { $0.identifiableBy ?? "" }
                let mixed: [(LocalPerson, User?)] = self.addressBook.localPeople.map {
                    if let index = find(userIdentifiers, $0.identifier) {
                        return ($0, users[index])
                    }
                    return ($0, .None)
                }
                self.setContacts(mixed)
            },
            failure: { _ in
                let contacts: [(LocalPerson, User?)] = self.addressBook.localPeople.map { ($0, .None) }
                self.setContacts(contacts)
                self.streamViewController.doneLoading()
            }
        )
    }
}

extension AddFriendsViewController: SearchScreenDelegate {

    public func searchCanceled() {
        navigationController?.popViewControllerAnimated(true)
    }

    public func searchFieldCleared() {
        streamViewController.streamFilter = nil
    }

    public func searchFieldChanged(text: String, isPostSearch: Bool) {
        if count(text) < 2 { return }
        if text.isEmpty {
            streamViewController.streamFilter = nil
        } else {
            streamViewController.streamFilter = { item in
                if let user = item.jsonable as? User {
                    return user.name.contains(text) || user.username.contains(text)
                }
                else if let person = item.jsonable as? LocalPerson {
                    return person.name.contains(text) || person.emails.reduce(false) { $0 || $1.contains(text) }
                }
                return false
            }
        }
    }

    public func toggleChanged(text: String, isPostSearch: Bool) {
        // do nothing as this should not be visible
    }

    public func findFriendsTapped() {
        // noop
    }

}
