//
//  AwesomePeopleSelectionViewController.swift
//  Ello
//
//  Created by Colin Gray on 5/14/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public class AwesomePeopleSelectionViewController: StreamableViewController {
    weak var onboardingViewController: OnboardingViewController?

    override public func viewDidLoad() {
        super.viewDidLoad()

        streamViewController.streamKind = .UserList(endpoint: .AwesomePeopleStream, title: "Awesome People")
        streamViewController.pullToRefreshEnabled = false
        streamViewController.allOlderPagesLoaded = true
        ElloHUD.showLoadingHudInView(streamViewController.view)
        streamViewController.initialLoadClosure = self.loadAwesomePeople
        streamViewController.loadInitialPage()

        onboardingViewController?.canGoNext = false
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

    private func loadAwesomePeople() {
        ElloProvider.sharedProvider = ElloProvider.StubbingProvider()
        streamViewController.streamService.loadStream(
            streamViewController.streamKind.endpoint,
            streamKind: streamViewController.streamKind,
            success: { (jsonables, responseConfig) in
                ElloProvider.sharedProvider = ElloProvider.DefaultProvider()
                if let users = jsonables as? [User] {
                    self.awesomePeopleLoaded(users, responseConfig: responseConfig)
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

    private func awesomePeopleLoaded(users: [User], responseConfig: ResponseConfig) {
        let index = streamViewController.refreshableIndex ?? 0
        streamViewController.dataSource.removeCellItemsBelow(index)
        streamViewController.collectionView.reloadData()

        let header = NSLocalizedString("Follow some awesome people.", comment: "Awesome People Selection Header text")
        let message = NSLocalizedString("Ello is full of interesting and creative people committed to building a positive community.", comment: "Awesome People Selection Description text")
        var headerItem = StreamCellItem(jsonable: JSONAble(version: 1), type: StreamCellType.OnboardingHeader, data: (header, message), oneColumnCellHeight: OnboardingHeaderCellHeight, multiColumnCellHeight: OnboardingHeaderCellHeight, isFullWidth: true)
        let userCount = count(users)
        var followAllItem = StreamCellItem(jsonable: JSONAble(version: 1), type: StreamCellType.FollowAll, data: userCount, oneColumnCellHeight: FollowAllCellHeight, multiColumnCellHeight: FollowAllCellHeight, isFullWidth: true)
        var items: [StreamCellItem] = StreamCellItemParser().parse(users, streamKind: streamViewController.streamKind)
        streamViewController.appendStreamCellItems([headerItem, followAllItem])
        streamViewController.appendUnsizedCellItems(items, withWidth: view.frame.width)
        streamViewController.doneLoading()
    }

}
