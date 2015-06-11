//
//  AddFriendsViewController.swift
//  Ello
//
//  Created by Ryan Boyajian on 5/22/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit

public class AddFriendsViewController: StreamableViewController {

    @IBOutlet weak public var filterField: UITextField!
    @IBOutlet weak public var navigationBarTopConstraint: NSLayoutConstraint!
    var navigationBar: ElloNavigationBar!

    let addressBook: ContactList

    public let inviteService = InviteService()
    public var allContacts: [(LocalPerson, User?)] = []
    public var userTappedDelegate: UserTappedDelegate?

    required public init(addressBook: ContactList) {
        self.addressBook = addressBook
        super.init(nibName: nil, bundle: nil)
        self.title = NSLocalizedString("Find & invite your friends", comment: "Find Friends")
        streamViewController.initialLoadClosure = findFriendsFromContacts
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
//        setupFilterField()
    }

    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if isMovingToParentViewController() {
            showNavBars(false)
            updateInsets(navBar: navigationBar, streamController: streamViewController)
            ElloHUD.showLoadingHudInView(streamViewController.view)
            streamViewController.loadInitialPage()
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

    override func viewForStream() -> UIView {
        return view
    }

    public func setContacts(contacts: [(LocalPerson, User?)]) {
        allContacts = contacts
        var foundItems = [StreamCellItem]()
        var inviteItems = [StreamCellItem]()
        for contact in allContacts {
            var (person: LocalPerson, user: User?) = contact
            if user != nil {
                foundItems.append(StreamCellItem(jsonable: user!, type: StreamCellType.UserListItem, data: nil, oneColumnCellHeight: 56.0, multiColumnCellHeight: 56.0, isFullWidth: true))
            }
            else {
                if let currentUser = currentUser, let profile = currentUser.profile {
                    if !contains(person.emails, profile.email) {
                        inviteItems.append(StreamCellItem(jsonable: person, type: StreamCellType.InviteFriends, data: nil, oneColumnCellHeight: 56.0, multiColumnCellHeight: 56.0, isFullWidth: true))
                    }

                }
            }
        }
        foundItems.sort { ($0.jsonable as! User).username < ($1.jsonable as! User).username }
        inviteItems.sort { ($0.jsonable as! LocalPerson).name < ($1.jsonable as! LocalPerson).name }
        // this calls doneLoading when cells are added
        streamViewController.appendUnsizedCellItems(foundItems + inviteItems, withWidth: self.view.frame.width)
    }

    // MARK: - Private

    private func setupNavBar() {
        navigationBar = ElloNavigationBar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: ElloNavigationBar.Size.height))
        navigationBar.autoresizingMask = .FlexibleBottomMargin | .FlexibleWidth
        view.addSubview(navigationBar)
        let item = UIBarButtonItem.backChevronWithTarget(self, action: Selector("backTapped:"))
        navigationItem.leftBarButtonItems = [item]
        navigationItem.fixNavBarItemPadding()
        navigationBar.items = [navigationItem]
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
        InviteService().find(contacts,
            currentUser: self.currentUser,
            success: { users in
                self.streamViewController.clearForInitialLoad()
                let userIdentifiers = users.map { $0.identifiableBy ?? "" }
                let mixed: [(LocalPerson, User?)] = self.addressBook.localPeople.map {
                    if let index = find(userIdentifiers, $0.identifier) {
                        return ($0, users[index])
                    }
                    return ($0, .None)
                }
                self.setContacts(mixed)
            },
            failure: { _ in
                let contacts: [(LocalPerson, User?)] = self.addressBook.localPeople.map { ($0, .None) }
                self.setContacts(contacts)
                self.streamViewController.doneLoading()
            }
        )
    }

    // MARK: - IBActions

    @IBAction public func filterFieldDidChange(sender: UITextField) {
//        if sender.text.isEmpty {
//            setDataSource(allContacts)
//        } else {
//            let filtered = allContacts.filter { (person, _) in
//                person.name.contains(sender.text) || person.emails.reduce(false) { $0 || $1.contains(sender.text) }
//            }
//            setDataSource(filtered)
//        }
//        tableView.reloadData()
    }
}

// MARK: InviteFriendsViewController : UITableViewDelegate
//extension AddFriendsViewController : UITableViewDelegate {
//    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        return 60.0
//    }
//
//    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        if let addFriendsCellItem = dataSource.itemAtIndexPath(indexPath), let user = addFriendsCellItem.user {
//            userTappedDelegate?.userTapped(user)
//        }
//    }
//}

// MARK: InviteFriendsViewController : UIScrollViewDelegate
//extension AddFriendsViewController : UIScrollViewDelegate {
//    public func scrollViewDidScroll(scrollView: UIScrollView) {
//        filterField.resignFirstResponder()
//    }
//}
