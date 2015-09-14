//
//  FoundersSelectionViewController.swift
//  Ello
//
//  Created by Colin Gray on 5/14/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public class FoundersSelectionViewController: OnboardingUserListViewController {

    override public func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Onboarding Founders Selection"
    }

    override func setupStreamController() {
        super.setupStreamController()

        streamViewController.streamKind = .SimpleStream(endpoint: .FoundersStream, title: "Founders")
    }

    override func loadUsers() {
        ElloProvider.sharedProvider = ElloProvider.StubbingProvider()
        super.loadUsers()
    }

    override func usersLoaded(users: [User]) {
        let header = NSLocalizedString("Follow the founders.", comment: "Founders Selection Header text")
        let message = NSLocalizedString("PLACEHOLDER TEXT.", comment: "Founders Selection Description text")
        appendHeaderCellItem(header: header, message: message)
        appendFollowAllCellItem(userCount: users.count)

        super.usersLoaded(users)
    }

}
