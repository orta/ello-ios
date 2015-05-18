//
//  OnboardingUserListViewController.swift
//  Ello
//
//  Created by Colin Gray on 5/14/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public class OnboardingUserListViewController: StreamableViewController, OnboardingStep, FollowAllButtonResponder {
    weak var onboardingViewController: OnboardingViewController?

    var headerItem: StreamCellItem?
    var followAllItem: StreamCellItem?
    var users: [User]?

    override func setupStreamController() {
        super.setupStreamController()

        streamViewController.pullToRefreshEnabled = false
        streamViewController.allOlderPagesLoaded = true
        streamViewController.initialLoadClosure = self.loadUsers
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        streamViewController.loadInitialPage()

        onboardingViewController?.canGoNext = false
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

    func onFollowAll() {
        if let users = users {
            let userCount = count(users)
            followAllItem?.data = (userCount, userCount)
            streamViewController.reloadCells()
        }
    }

    func appendHeaderCellItem(#header: String, message: String) {
        let anyHeight = CGFloat(120)
        let headerItem = StreamCellItem(jsonable: JSONAble(version: 1), type: StreamCellType.OnboardingHeader, data: (header, message), oneColumnCellHeight: anyHeight, multiColumnCellHeight: anyHeight, isFullWidth: true)
        self.headerItem = headerItem
        streamViewController.appendStreamCellItems([headerItem])
    }

    func appendFollowAllCellItem(#userCount: Int) {
        let followAllItem = StreamCellItem(jsonable: JSONAble(version: 1), type: StreamCellType.FollowAll, data: (userCount, 0), oneColumnCellHeight: FollowAllCellHeight, multiColumnCellHeight: FollowAllCellHeight, isFullWidth: true)
        self.followAllItem = followAllItem
        streamViewController.appendStreamCellItems([followAllItem])
    }

}
