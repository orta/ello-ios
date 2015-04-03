//
//  InviteFriendsViewController.swift
//  Ello
//
//  Created by Sean on 2/26/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit

public class InviteFriendsViewController: BaseElloViewController {

    @IBOutlet weak public var tableView: UITableView!
    @IBOutlet weak public var filterField: UITextField!

    public let dataSource = AddFriendsDataSource()
    public let inviteService = InviteService()
    private var relationshipController: RelationshipController?
    public var allContacts: [(LocalPerson, User?)] = []

    required public init() {
        super.init(nibName: "InviteFriendsViewController", bundle: NSBundle(forClass: InviteFriendsViewController.self))
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupFilterField()
    }

    public func setContacts(contacts: [(LocalPerson, User?)]) {
        allContacts = contacts
        setDataSource(allContacts)
        dispatch_async(dispatch_get_main_queue()) { _ = self.tableView?.reloadData() }
    }

    private func setDataSource(contacts: [(LocalPerson, User?)]) {
        dataSource.items = contacts.map { AddFriendsCellItem(person: $0.0, user: $0.1) }
    }

    private func setupTableView() {
        registerCells()

        relationshipController = RelationshipController(presentingController: self)
        dataSource.relationshipDelegate = relationshipController

        tableView.dataSource = dataSource
        tableView.delegate = self
    }

    private func setupFilterField() {
        filterField.font = UIFont.regularBoldFont(18)
        filterField.textColor = UIColor.greyA()
    }

    private func registerCells() {
        let findCellNib = UINib(nibName: AddFriendsCellItem.CellType.Find.identifier, bundle: NSBundle(forClass: FindFriendsCell.self))
        tableView.registerNib(findCellNib, forCellReuseIdentifier: AddFriendsCellItem.CellType.Find.identifier)

        let inviteCellNib = UINib(nibName: AddFriendsCellItem.CellType.Invite.identifier, bundle: NSBundle(forClass: InviteFriendsCell.self))
        tableView.registerNib(inviteCellNib, forCellReuseIdentifier: AddFriendsCellItem.CellType.Invite.identifier)
    }

    @IBAction public func filterFieldDidChange(sender: UITextField) {
        if sender.text.isEmpty {
            setDataSource(allContacts)
        } else {
            let filtered = allContacts.filter { (person, _) in
                person.name.contains(sender.text) || person.emails.reduce(false) { $0 || $1.contains(sender.text) }
            }
            setDataSource(filtered)
        }
        tableView.reloadData()
    }
}

// MARK: InviteFriendsViewController : UITableViewDelegate
extension InviteFriendsViewController : UITableViewDelegate {
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }
}

// MARK: InviteFriendsViewController : UIScrollViewDelegate
extension InviteFriendsViewController : UIScrollViewDelegate {
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        filterField.resignFirstResponder()
    }
}
