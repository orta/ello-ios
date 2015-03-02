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
    @IBOutlet weak var inviteButton: ElloButton!
    var dataSource:AddFriendsDataSource!
    let inviteService = InviteService()

    required override init() {
        super.init(nibName: "InviteFriendsViewController", bundle: NSBundle(forClass: InviteFriendsViewController.self))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }

    private func setupTableView() {
        registerCells()
        dataSource = AddFriendsDataSource()
        tableView.dataSource = dataSource
        tableView.delegate = self
    }

    private func registerCells() {
        let findCellNib = UINib(nibName: AddFriendsCellItem.CellType.Find.identifier, bundle: NSBundle(forClass: FindFriendsCell.self))
        tableView.registerNib(findCellNib, forCellReuseIdentifier: AddFriendsCellItem.CellType.Find.identifier)

        let inviteCellNib = UINib(nibName: AddFriendsCellItem.CellType.Invite.identifier, bundle: NSBundle(forClass: InviteFriendsCell.self))
        tableView.registerNib(inviteCellNib, forCellReuseIdentifier: AddFriendsCellItem.CellType.Invite.identifier)
    }

    // MARK: - IBActions

    @IBAction func inviteTapped(sender: UIButton) {
        // send off the selected email addresses
    }
}

// MARK: InviteFriendsViewController : UITableViewDelegate
extension InviteFriendsViewController : UITableViewDelegate {

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50.0
    }
}
