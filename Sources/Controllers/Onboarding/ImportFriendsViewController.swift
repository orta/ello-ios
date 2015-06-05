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

        var contacts = [String: [String]]()
        for person in addressBook.localPeople {
            contacts[person.identifier] = person.emails
        }

        streamViewController.streamKind = .UserList(endpoint: .FindFriends(contacts: contacts), title: "Find Friends")
        let noResultsTitle = NSLocalizedString("Thanks!", comment: "Import friends no results title")
        let noResultsBody = NSLocalizedString("We didn’t find any of your friends on Ello.\n\nWhen your friends join Ello you’ll be able to find and invite them on the Discover screen.", comment: "Import friends no results body.")
        streamViewController.noResultsMessages = (title: noResultsTitle, body: noResultsBody)
    }

    override func usersLoaded(users: [User]) {
        let filteredUsers = InviteService.filterUsers(users, currentUser: currentUser)
        let header = NSLocalizedString("Find your friends!", comment: "Find Friends Header text")
        let message = NSLocalizedString("Use your address book to find and invite your friends on Ello.", comment: "Find Friends Description text")
        appendHeaderCellItem(header: header, message: message)
        appendFollowAllCellItem(userCount: count(filteredUsers))

        super.usersLoaded(filteredUsers)
    }

}
