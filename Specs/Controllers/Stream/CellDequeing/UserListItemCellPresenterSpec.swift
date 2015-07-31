//
//  UserListItemCellPresenterSpec.swift
//  Ello
//
//  Created by Ryan Boyajian on 6/12/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble

class UserListItemCellPresenterSpec: QuickSpec {

    override func spec() {

        describe("configure") {

            it("sets the relationship priority and username") {
                let cell: UserListItemCell = UserListItemCell.loadFromNib()
                let user: User = stub([
                    "relationshipPriority": "friend",
                    "username": "sterling_archer"
                    ])
                var item = StreamCellItem(jsonable: user, type: .UserListItem)

                UserListItemCellPresenter.configure(cell, streamCellItem: item, streamKind: StreamKind.UserStream(userParam: user.id), indexPath: NSIndexPath(forItem: 0, inSection: 0), currentUser: nil)

                expect(cell.relationshipControl.relationshipPriority) == RelationshipPriority.Friend
                expect(cell.usernameLabel.text) == "@sterling_archer"
            }

        }

    }
}
