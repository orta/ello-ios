//
//  InviteFriendsViewController.swift
//  Ello
//
//  Created by Sean on 2/26/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit

class InviteFriendsViewController: BaseElloViewController {

    @IBOutlet weak var tableView: UITableView!
    var dataSource:AddFriendsDataSource!
    let inviteService = InviteService()
    var relationshipController: RelationshipController?

    required override init() {
        super.init(nibName: "InviteFriendsViewController", bundle: NSBundle(forClass: InviteFriendsViewController.self))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }

    func setContacts(contacts: [(LocalPerson, User?)]) {
        dataSource.items = contacts.map { AddFriendsCellItem(person: $0.0, user: $0.1) }
        dispatch_async(dispatch_get_main_queue()) { self.tableView.reloadData() }
    }

    private func setupTableView() {
        registerCells()
        dataSource = AddFriendsDataSource()

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

// MARK: InviteFriendsViewController : UITableViewDelegate
extension InviteFriendsViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50.0
    }
}
