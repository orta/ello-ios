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

}

extension OnboardingUserListViewController {

    public func relationshipChanged(userId: String, status: RelationshipRequestStatus, relationship: Relationship?) {
        if status == .Failure {
            showRelationshipFailureAlert()
        }
        // add or remove userId to the "followed" list, which gets passed from
        // "community selection" to the "awesome people" endpoint
    }

    func onFollowAll() {
        if let users = users {
            let userIds = users.map { $0.id }
            ElloHUD.showLoadingHud()
            RelationshipService().bulkUpdateRelationships(userIds: userIds, relationship: .Friend,
                success: { data in
                    ElloHUD.hideLoadingHud()
                    let userCount = count(users)
                    self.followAllItem?.data = FollowAllCounts(userCount: userCount, followedCount: userCount)

                    let userItems = self.streamViewController.dataSource.streamCellItems.filter { (item: StreamCellItem) in return item.type == .UserListItem }
                    for streamCellItem in userItems {
                        if let user = streamCellItem.jsonable as? User {
                            user.relationshipPriority = .Friend
                        }
                    }
                    self.streamViewController.reloadCells()
                },
                failure: { _ in
                    ElloHUD.hideLoadingHud()
                    self.showRelationshipFailureAlert()
                })
        }
    }

    private func showRelationshipFailureAlert() {
        let message = NSLocalizedString("Oh no! Something went wrong.\n\nTry that again maybe?", comment: "Relationship status update failed during onboarding message")
        let alertController = AlertViewController(message: message)

        let action = AlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .Dark, handler: nil)
        alertController.addAction(action)

        self.presentViewController(alertController, animated: true, completion: nil)
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
