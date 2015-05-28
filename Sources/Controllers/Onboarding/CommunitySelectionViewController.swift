//
//  CommunitySelectionViewController.swift
//  Ello
//
//  Created by Colin Gray on 5/12/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public class CommunitySelectionViewController: OnboardingUserListViewController {

    override public func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Onboarding Community Selection"
    }

    override func setupStreamController() {
        super.setupStreamController()

        streamViewController.streamKind = .UserList(endpoint: .CommunitiesStream, title: "Communities")
    }

    override func usersLoaded(users: [User]) {
        let header = NSLocalizedString("What are you interested in?", comment: "Community Selection Header text")
        let message = NSLocalizedString("Follow the Ello communities that you find most inspiring.", comment: "Community Selection Description text")
        appendHeaderCellItem(header: header, message: message)

        super.usersLoaded(users)
    }

}
