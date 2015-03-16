//
//  DrawerViewDataSource.swift
//  Ello
//
//  Created by Gordon Fontenot on 3/16/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

class DrawerViewDataSource {
    private let relationship: Relationship
    private var users: [User] = []

    var numberOfUsers: Int {
        return users.count
    }

    init(relationship: Relationship) {
        self.relationship = relationship
    }

    func refreshUsers(completion: () -> ()) {
        ProfileService().loadCurrentUserFollowing(forRelationship: relationship, success: { users in
            self.users = users
            dispatch_async(dispatch_get_main_queue(), completion)
        }, failure: .None)
    }

    func userForIndexPath(indexPath: NSIndexPath) -> User {
        return users[indexPath.row]
    }
}
