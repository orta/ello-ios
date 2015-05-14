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

        streamViewController.streamKind = .UserList(endpoint: .CommunitiesStream, title: "Communities")
        streamViewController.loadInitialPage()

        onboardingViewController?.canGoNext = false
    }

    override func usersLoaded(users: [User]) {
        let headerHeight = CGFloat(120)
        let header = NSLocalizedString("What are you interested in?", comment: "Community Selection Header text")
        let message = NSLocalizedString("Follow the Ello communities that you find most inspiring.", comment: "Community Selection Description text")
        appendHeaderCellItem(header: header, message: message, headerHeight: headerHeight)

        super.usersLoaded(users)
    }

}
