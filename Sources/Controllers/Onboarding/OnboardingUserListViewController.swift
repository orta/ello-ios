//
//  OnboardingUserListViewController.swift
//  Ello
//
//  Created by Colin Gray on 5/14/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public class OnboardingUserListViewController: StreamableViewController, OnboardingStep {
    weak var onboardingViewController: OnboardingViewController?

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
        ElloProvider.sharedProvider = ElloProvider.StubbingProvider()
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
        var items: [StreamCellItem] = StreamCellItemParser().parse(users, streamKind: streamViewController.streamKind)
        streamViewController.appendUnsizedCellItems(items, withWidth: view.frame.width)
        streamViewController.doneLoading()
    }

    func appendHeaderCellItem(#header: String, message: String, headerHeight: CGFloat) {
        var headerItem = StreamCellItem(jsonable: JSONAble(version: 1), type: StreamCellType.OnboardingHeader, data: (header, message), oneColumnCellHeight: headerHeight, multiColumnCellHeight: headerHeight, isFullWidth: true)
        streamViewController.appendStreamCellItems([headerItem])
    }

    func appendFollowAllCellItem(#userCount: Int) {
        var followAllItem = StreamCellItem(jsonable: JSONAble(version: 1), type: StreamCellType.FollowAll, data: userCount, oneColumnCellHeight: FollowAllCellHeight, multiColumnCellHeight: FollowAllCellHeight, isFullWidth: true)
        streamViewController.appendStreamCellItems([followAllItem])
    }

}
