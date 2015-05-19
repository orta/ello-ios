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

    override func setupStreamController() {
        super.setupStreamController()

        var contacts = [String: [String]]()
        for person in addressBook.localPeople {
            contacts[person.identifier] = person.emails
        }

        streamViewController.streamKind = .UserList(endpoint: .FindFriends(contacts: contacts), title: "Find Friends")
    }

    override func usersLoaded(users: [User]) {
        let filteredUsers = InviteService.filterUsers(users, currentUser: currentUser)
        let header = NSLocalizedString("Find your friends!", comment: "Find Friends Header text")
        let message = NSLocalizedString("Import and invite friends from your address book.", comment: "Find Friends Description text")
        appendHeaderCellItem(header: header, message: message)
        appendFollowAllCellItem(userCount: count(filteredUsers))

        super.usersLoaded(filteredUsers)
    }

}
