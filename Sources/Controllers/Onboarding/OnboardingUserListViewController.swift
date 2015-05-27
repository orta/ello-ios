//
//  OnboardingUserListViewController.swift
//  Ello
//
//  Created by Colin Gray on 5/14/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public class OnboardingUserListViewController: StreamableViewController, OnboardingStep, FollowAllButtonResponder, RelationshipControllerDelegate {
    weak var onboardingViewController: OnboardingViewController?
    var onboardingData: OnboardingData?

    var headerItem: StreamCellItem?
    var followAllItem: StreamCellItem?
    var users: [User]?

    override func setupStreamController() {
        super.setupStreamController()

        streamViewController.pullToRefreshEnabled = false
        streamViewController.allOlderPagesLoaded = true
        streamViewController.initialLoadClosure = self.loadUsers
        streamViewController.relationshipController?.delegate = self
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        streamViewController.loadInitialPage()

        ElloHUD.showLoadingHudInView(streamViewController.view)
    }

    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateCanGoNextButton()
    }

    override func viewForStream() -> UIView {
        return view
    }

    override public func didSetCurrentUser() {
        if isViewLoaded() {
            streamViewController.currentUser = currentUser
        }
        super.didSetCurrentUser()
    }

    func appendHeaderCellItem(#header: String, message: String) {
        let anyHeight = CGFloat(120)
        let headerItem = StreamCellItem(jsonable: JSONAble(version: 1), type: StreamCellType.OnboardingHeader, data: (header, message), oneColumnCellHeight: anyHeight, multiColumnCellHeight: anyHeight, isFullWidth: true)
        self.headerItem = headerItem
        streamViewController.appendStreamCellItems([headerItem])
    }

    func appendFollowAllCellItem(#userCount: Int) {
        let data = FollowAllCounts(userCount: userCount, followedCount: 0)
        let followAllItem = StreamCellItem(jsonable: JSONAble(version: 1), type: StreamCellType.FollowAll, data: data, oneColumnCellHeight: FollowAllCellHeight, multiColumnCellHeight: FollowAllCellHeight, isFullWidth: true)
        self.followAllItem = followAllItem
        streamViewController.appendStreamCellItems([followAllItem])
    }

    public func onboardingWillProceed(proceed: (OnboardingData?) -> Void) {
        let users = userItems().map { $0.jsonable as! User }
        let friendUserIds = users.filter { (user: User) -> Bool in return user.relationshipPriority == .Friend }.map { $0.id }
        let noiseUserIds = users.filter { (user: User) -> Bool in return user.relationshipPriority == .Noise }.map { $0.id }

        if count(noiseUserIds) > 0 {
            println("Submit this to Tracker?")
        }

        ElloHUD.showLoadingHud()
        RelationshipService().bulkUpdateRelationships(userIds: friendUserIds, relationship: .Friend,
            success: { data in
                ElloHUD.hideLoadingHud()
                proceed(self.onboardingData)
            },
            failure: { _ in
                ElloHUD.hideLoadingHud()
                self.showRelationshipFailureAlert()
            })
    }

    private func showRelationshipFailureAlert() {
        let message = NSLocalizedString("Oh no! Something went wrong.\n\nTry that again maybe?", comment: "Relationship status update failed during onboarding message")
        let alertController = AlertViewController(message: message)

        let action = AlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .Dark, handler: nil)
        alertController.addAction(action)

        self.presentViewController(alertController, animated: true, completion: nil)
    }

// MARK: RelationshipControllerDelegate

    public func shouldSubmitRelationship(userId: String, relationshipPriority: RelationshipPriority) -> Bool {
        var users = [User]()
        let jsonables = streamViewController.dataSource.streamCellItems.map { (item: StreamCellItem) in return item.jsonable }
        for jsonable in jsonables {
            if let user = jsonable as? User where user.id == userId {
                user.relationshipPriority = relationshipPriority
                break
            }
        }

        updateFollowAllItem()
        updateCanGoNextButton()
        return false
    }

    public func relationshipChanged(userId: String, status: RelationshipRequestStatus, relationship: Relationship?) {
    }

}

extension OnboardingUserListViewController {

    private func userItems() -> [StreamCellItem] {
        return streamViewController.dataSource.streamCellItems.filter { (item: StreamCellItem) in return item.type == .UserListItem }
    }

    func followedCount() -> Int {
        if let users = users {
            return users.reduce(0) { (followedCount: Int, user: User) -> Int in
                if user.relationshipPriority == .Friend || user.relationshipPriority == .Noise {
                    return followedCount + 1
                }
                return followedCount
            }
        }
        return 0
    }

    func updateFollowAllItem() {
        updateFollowAllItem(userCount: count(users ?? []), followedCount: followedCount())
    }

    func updateFollowAllItem(#userCount: Int, followedCount: Int) {
        followAllItem?.data = FollowAllCounts(userCount: userCount, followedCount: followedCount)
        streamViewController.reloadCells()
    }

    func updateCanGoNextButton() {
        updateCanGoNextButton(followedCount: followedCount())
    }

    func updateCanGoNextButton(#followedCount: Int) {
        onboardingViewController?.canGoNext = followedCount > 0
    }

    func onFollowAll() {
        if let users = users {
            let userCount = count(users)
            let newPriority: RelationshipPriority
            if userCount == followedCount() {
                friendNone(users)
            }
            else {
                friendAll(users)
            }
        }
    }

    func friendAll(users: [User]) {
        setAllRelationships(users, relationship: .Friend)
    }

    func friendNone(users: [User]) {
        setAllRelationships(users, relationship: .None)
    }

    func setAllRelationships(users: [User], relationship: RelationshipPriority) {
        for user in users {
            user.relationshipPriority = relationship
        }

        let userCount = count(users)
        let followedCount: Int
        if relationship == .None {
            followedCount = 0
        }
        else {
            followedCount = userCount
        }

        updateFollowAllItem(userCount: userCount, followedCount: followedCount)
        updateCanGoNextButton(followedCount: followedCount)
    }

}

extension OnboardingUserListViewController {

    func loadUsers() {
        streamViewController.streamService.loadStream(
            streamViewController.streamKind.endpoint,
            streamKind: streamViewController.streamKind,
            success: { (jsonables, responseConfig) in
                ElloProvider.sharedProvider = ElloProvider.DefaultProvider()
                if let users = jsonables as? [User] {
                    self.usersLoaded(users)
                }
                else {
                    self.streamViewController.doneLoading()
                }
            },
            failure: { (error, statusCode) in
                ElloProvider.sharedProvider = ElloProvider.DefaultProvider()
                self.streamViewController.doneLoading()
            }
        )
    }

    func usersLoaded(users: [User]) {
        self.users = users
        var items: [StreamCellItem] = StreamCellItemParser().parse(users, streamKind: streamViewController.streamKind)
        streamViewController.appendUnsizedCellItems(items, withWidth: view.frame.width)
        streamViewController.doneLoading()
    }

}
