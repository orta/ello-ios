//
//  AddFriendsDataSource.swift
//  Ello
//
//  Created by Sean on 2/26/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit

struct AddFriendsCellItem {
    let cellType: CellType
    let user: User?
    let person: LocalPerson?

    init(user: User) {
        cellType = .Find
        self.user = user
    }

    init(person: LocalPerson) {
        cellType = .Invite
        self.person = person
    }

    enum CellType {
        case Find
        case Invite

        var identifier: String {
            switch self {
            case Find: return "FindFriendsCell"
            case Invite: return "InviteFriendsCell"
            }
        }
    }
}

class AddFriendsDataSource: NSObject, UITableViewDataSource {

    var items = [AddFriendsCellItem]()
    var relationshipDelegate: RelationshipDelegate?

    // MARK: Public

    func itemAtIndexPath(indexPath: NSIndexPath) -> AddFriendsCellItem? {
        if indexPath.row < countElements(items) {
            return items[indexPath.row]
        }
        return nil
    }

    // MARK: Private

    // MARK: UITableViewDataSource

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countElements(items)
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let item: AddFriendsCellItem = itemAtIndexPath(indexPath) {
            var cell = tableView.dequeueReusableCellWithIdentifier(item.cellType.identifier, forIndexPath: indexPath) as UITableViewCell
            AddFriendsCellPresenter.configure(cell, addFriendsCellItem: item, relationshipDelegate: relationshipDelegate)
            return cell
        }
        return UITableViewCell()
    }
}
