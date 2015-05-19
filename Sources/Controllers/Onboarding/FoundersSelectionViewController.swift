//
//  FoundersSelectionViewController.swift
//  Ello
//
//  Created by Colin Gray on 5/14/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public class FoundersSelectionViewController: OnboardingUserListViewController {

    override func setupStreamController() {
        super.setupStreamController()

        streamViewController.streamKind = .UserList(endpoint: .FoundersStream, title: "Founders")
    }

    override func loadUsers() {
        ElloProvider.sharedProvider = ElloProvider.StubbingProvider()
        super.loadUsers()
    }

    override func usersLoaded(users: [User]) {
        let header = NSLocalizedString("Follow the founders.", comment: "Founders Selection Header text")
        let message = NSLocalizedString("PLACEHOLDER TEXT.", comment: "Founders Selection Description text")
        appendHeaderCellItem(header: header, message: message)
        appendFollowAllCellItem(userCount: count(users))

        super.usersLoaded(users)
    }

}
