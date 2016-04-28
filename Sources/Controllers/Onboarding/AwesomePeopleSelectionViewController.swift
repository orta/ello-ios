//
//  AwesomePeopleSelectionViewController.swift
//  Ello
//
//  Created by Colin Gray on 5/14/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public class AwesomePeopleSelectionViewController: OnboardingUserListViewController {

    override public func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Onboarding Awesome People Selection"
    }

    override func setupStreamController() {
        super.setupStreamController()

        streamViewController.streamKind = .SimpleStream(endpoint: .AwesomePeopleStream, title: "Awesome People")
    }

    override func usersLoaded(users: [User]) {
        let header = InterfaceString.Onboard.AwesomePeople.Title
        let message = InterfaceString.Onboard.AwesomePeople.Description
        appendHeaderCellItem(header: header, message: message)
        appendFollowAllCellItem(userCount: users.count)

        friendAll(users)
        super.usersLoaded(users)
    }

}
