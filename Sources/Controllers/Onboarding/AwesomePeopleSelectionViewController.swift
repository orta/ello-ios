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

        streamViewController.streamKind = StreamKind.AwesomePeople
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
                    self.communityLoaded(users, responseConfig: responseConfig)
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

    private func communityLoaded(users: [User], responseConfig: ResponseConfig) {
        let index = streamViewController.refreshableIndex ?? 0
        streamViewController.dataSource.removeCellItemsBelow(index)
        streamViewController.collectionView.reloadData()

        let header = NSLocalizedString("What are you interested in?", comment: "Community Selection Header text")
        let message = NSLocalizedString("Follow the Ello communities that you find most inspiring.", comment: "Community Selection Description text")
        var headerItem = StreamCellItem(jsonable: JSONAble(version: 1), type: StreamCellType.OnboardingHeader, data: nil, oneColumnCellHeight: OnboardingHeaderCellHeight, multiColumnCellHeight: OnboardingHeaderCellHeight, isFullWidth: true)
//        var followAllItem = StreamCellItem(jsonable: JSONAble(version: 1), type: StreamCellType.FollowAll, data: nil, oneColumnCellHeight: OnboardingHeaderCellHeight, multiColumnCellHeight: OnboardingHeaderCellHeight, isFullWidth: true)
        var items: [StreamCellItem] = StreamCellItemParser().parse(users, streamKind: streamViewController.streamKind)
        streamViewController.appendStreamCellItems([headerItem])
        streamViewController.appendUnsizedCellItems(items, withWidth: view.frame.width)
        streamViewController.doneLoading()
    }

}
