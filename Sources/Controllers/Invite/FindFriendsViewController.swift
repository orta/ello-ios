//
//  FindFriendsViewController.swift
//  Ello
//
//  Created by Sean on 2/26/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit

public class FindFriendsViewController: BaseElloViewController {

    @IBOutlet weak public var tableView: UITableView!
    public let dataSource = AddFriendsDataSource()
    public let inviteService = InviteService()
    public var userTappedDelegate: UserTappedDelegate?
    var relationshipController: RelationshipController?

    required public init() {
        super.init(nibName: "FindFriendsViewController", bundle: NSBundle(forClass: FindFriendsViewController.self))
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }

    public func setUsers(users: [User]) {
        dataSource.items = users.map { AddFriendsCellItem(user: $0) }
        dispatch_async(dispatch_get_main_queue()) { self.tableView.reloadData() }
    }

    // MARK: - Private

    private func setupTableView() {
        registerCells()

        relationshipController = RelationshipController(presentingController: self)
        dataSource.relationshipDelegate = relationshipController

        tableView.dataSource = dataSource
        tableView.delegate = self
    }

    private func registerCells() {
        let findCellNib = UINib(nibName: AddFriendsCellItem.CellType.Find.identifier, bundle: NSBundle(forClass: FindFriendsCell.self))
        tableView.registerNib(findCellNib, forCellReuseIdentifier: AddFriendsCellItem.CellType.Find.identifier)

        let inviteCellNib = UINib(nibName: AddFriendsCellItem.CellType.Invite.identifier, bundle: NSBundle(forClass: InviteFriendsCell.self))
        tableView.registerNib(inviteCellNib, forCellReuseIdentifier: AddFriendsCellItem.CellType.Invite.identifier)
    }
}

// MARK: FindFriendsViewController : UITableViewDelegate
extension FindFriendsViewController : UITableViewDelegate {

    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }
}
