//
//  AwesomePeopleSelectionViewController.swift
//  Ello
//
//  Created by Colin Gray on 5/14/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public class AwesomePeopleSelectionViewController: OnboardingUserListViewController {

    override func setupStreamController() {
        super.setupStreamController()

        streamViewController.streamKind = .UserList(endpoint: .AwesomePeopleStream, title: "Awesome People")
    }

    override func usersLoaded(users: [User]) {
        let headerHeight = CGFloat(141)
        let header = NSLocalizedString("Follow some awesome people.", comment: "Awesome People Selection Header text")
        let message = NSLocalizedString("Ello is full of interesting and creative people committed to building a positive community.", comment: "Awesome People Selection Description text")
        appendHeaderCellItem(header: header, message: message, headerHeight: headerHeight)
        appendFollowAllCellItem(userCount: count(users))

        super.usersLoaded(users)
    }

}
