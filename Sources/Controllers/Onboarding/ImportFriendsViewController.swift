//
//  ImportFriendsViewController.swift
//  Ello
//
//  Created by Colin Gray on 5/15/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public class ImportFriendsViewController: OnboardingUserListViewController, OnboardingStep {
    let addressBook: ContactList

    required public init(addressBook: ContactList) {
        self.addressBook = addressBook
        super.init(nibName: nil, bundle: NSBundle(forClass: ImportFriendsViewController.self))
        self.title = "Onboarding Find Friends"
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Onboarding Import Friends"
    }

    override func setupStreamController() {
        super.setupStreamController()
        let noResultsTitle = NSLocalizedString("Find your friends!", comment: "Import friends no results title")
        let noResultsBody = NSLocalizedString("Thanks. We didn’t find any of your friends.\n\nWhen your friends join Ello you’ll be able to find and invite them on the Discover and Search screen.", comment: "Import friends no results body.")
        streamViewController.noResultsMessages = (title: noResultsTitle, body: noResultsBody)
        streamViewController.initialLoadClosure = findFriendsFromContacts
    }

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

    public func setContacts(contacts: [(LocalPerson, User?)]) {
        var foundItems = [StreamCellItem]()
        var inviteItems = [StreamCellItem]()
        for contact in contacts {
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
        users = foundItems.map { $0.jsonable as! User }
        let filteredUsers = InviteService.filterUsers(users!, currentUser: currentUser)
        let header = NSLocalizedString("Find your friends!", comment: "Find Friends Header text")
        let message = NSLocalizedString("Use your address book to find and invite your friends on Ello.", comment: "Find Friends Description text")
        appendHeaderCellItem(header: header, message: message)
        appendFollowAllCellItem(userCount: count(filteredUsers))
        // this calls doneLoading when cells are added
        streamViewController.appendUnsizedCellItems(foundItems + inviteItems, withWidth: self.view.frame.width)
    }

}
