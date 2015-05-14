//
//  CommunitySelectionViewController.swift
//  Ello
//
//  Created by Colin Gray on 5/12/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public class CommunitySelectionViewController: StreamableViewController, OnboardingStep {
    weak var onboardingViewController: OnboardingViewController?

    override public func viewDidLoad() {
        super.viewDidLoad()

        streamViewController.streamKind = StreamKind.Communities
        streamViewController.pullToRefreshView?.removeFromSuperview()
        ElloHUD.showLoadingHudInView(streamViewController.view)
        streamViewController.initialLoadClosure = self.loadCommunity
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

    private func loadCommunity() {
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
        streamViewController.allOlderPagesLoaded = false
        streamViewController.dataSource.removeCellItemsBelow(index)
        streamViewController.collectionView.reloadData()

        var header = StreamCellItem(jsonable: JSONAble(version: 1), type: StreamCellType.OnboardingHeader, data: nil, oneColumnCellHeight: OnboardingHeaderCellHeight, multiColumnCellHeight: OnboardingHeaderCellHeight, isFullWidth: true)
        var items: [StreamCellItem] = StreamCellItemParser().parse(users, streamKind: streamViewController.streamKind)
        streamViewController.appendStreamCellItems([header])
        streamViewController.appendUnsizedCellItems(items, withWidth: view.frame.width)
        streamViewController.doneLoading()
    }

}
