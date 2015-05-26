//
//  AddFriendsViewController.swift
//  Ello
//
//  Created by Ryan Boyajian on 5/22/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit

public class AddFriendsViewController: StreamableViewController {

    @IBOutlet weak public var tableView: UITableView!
    @IBOutlet weak public var filterField: UITextField!
    @IBOutlet weak public var navigationBar: UINavigationBar!
    @IBOutlet weak public var navigationBarTopConstraint: NSLayoutConstraint!

    let addressBook: ContactList

    public let dataSource = AddFriendsDataSource()
    public let inviteService = InviteService()
    public var allContacts: [(LocalPerson, User?)] = []
    public var userTappedDelegate: UserTappedDelegate?

    private var relationshipController: RelationshipController?

    required public init(addressBook: ContactList) {
        self.addressBook = addressBook
        super.init(nibName: "AddFriendsViewController", bundle: NSBundle(forClass: AddFriendsViewController.self))
        self.title = NSLocalizedString("Find Friends", comment: "Find Friends")
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // TODO: remove this and convert to streamViewController
    override func setupStreamController() {
        // noop
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupTableView()
        setupFilterField()
    }

    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if isMovingToParentViewController() {
            findFriendsFromContacts()
            updateInsets()
        }
    }

    override func showNavBars(scrollToBottom : Bool) {
        super.showNavBars(scrollToBottom)
        positionNavBar(navigationBar, visible: true, withConstraint: navigationBarTopConstraint)
    }

    override func hideNavBars() {
        super.hideNavBars()
        positionNavBar(navigationBar, visible: false, withConstraint: navigationBarTopConstraint)
    }

    public func setContacts(contacts: [(LocalPerson, User?)]) {
        allContacts = contacts
        setDataSource(allContacts)
        dispatch_async(dispatch_get_main_queue()) { _ = self.tableView?.reloadData() }
    }

    // MARK: - Private

    private func updateInsets() {
        tableView.contentInset.bottom = ElloTabBar.Size.height
        tableView.scrollIndicatorInsets.bottom = ElloTabBar.Size.height
    }

    private func setupNavBar() {
        navigationController?.navigationBarHidden = true
        navigationItem.title = self.title
        navigationBar.items = [navigationItem]
        if !isRootViewController() {
            let item = UIBarButtonItem.backChevronWithTarget(self, action: Selector("backTapped:"))
            self.navigationItem.leftBarButtonItems = [item]
            self.navigationItem.fixNavBarItemPadding()
        }
    }

    private func setupTableView() {
        registerCells()

        relationshipController = RelationshipController(presentingController: self)
        dataSource.relationshipDelegate = relationshipController

        tableView.dataSource = dataSource
        tableView.delegate = self
        tableView.allowsSelection = true
    }

    private func registerCells() {
        let findCellNib = UINib(nibName: AddFriendsCellItem.CellType.Find.identifier, bundle: NSBundle(forClass: FindFriendsCell.self))
        tableView.registerNib(findCellNib, forCellReuseIdentifier: AddFriendsCellItem.CellType.Find.identifier)

        let inviteCellNib = UINib(nibName: AddFriendsCellItem.CellType.Invite.identifier, bundle: NSBundle(forClass: InviteFriendsCell.self))
        tableView.registerNib(inviteCellNib, forCellReuseIdentifier: AddFriendsCellItem.CellType.Invite.identifier)
    }

    private func setupFilterField() {
        filterField.font = UIFont.regularBoldFont(18)
        filterField.textColor = UIColor.greyA()
    }

    private func findFriendsFromContacts() {
        var contacts = [String: [String]]()
        for person in addressBook.localPeople {
            contacts[person.identifier] = person.emails
        }

        ElloHUD.showLoadingHudInView(self.tableView)
        InviteService().find(contacts, currentUser: self.currentUser, success: { users in
            let userIdentifiers = users.map { $0.identifiableBy ?? "" }
            let mixed: [(LocalPerson, User?)] = self.addressBook.localPeople.map {
                if let index = find(userIdentifiers, $0.identifier) {
                    return ($0, users[index])
                }
                return ($0, .None)
            }
            self.setContacts(mixed)
            ElloHUD.hideLoadingHudInView(self.tableView)
            }, failure: { _ in
                let contacts: [(LocalPerson, User?)] = self.addressBook.localPeople.map { ($0, .None) }
                self.setContacts(contacts)
                ElloHUD.hideLoadingHudInView(self.tableView)
        })
    }

    private func setDataSource(contacts: [(LocalPerson, User?)]) {
        dataSource.items = contacts.map { AddFriendsCellItem(person: $0.0, user: $0.1) }
    }

    // MARK: - IBActions

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
extension AddFriendsViewController : UITableViewDelegate {
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }

    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let addFriendsCellItem = dataSource.itemAtIndexPath(indexPath), let user = addFriendsCellItem.user {
            userTappedDelegate?.userTapped(user)
        }
    }
}

// MARK: InviteFriendsViewController : UIScrollViewDelegate
extension AddFriendsViewController : UIScrollViewDelegate {
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        filterField.resignFirstResponder()
    }
}
