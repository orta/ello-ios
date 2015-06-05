//
//  SearchViewController.swift
//  Ello
//
//  Created by Colin Gray on 4/21/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public class SearchViewController: StreamableViewController {
    var userSearchText: String?

    var _mockScreen: SearchScreenProtocol?
    public var screen: SearchScreenProtocol {
        set(screen) { _mockScreen = screen }
        get { return _mockScreen ?? self.view as! SearchScreen }
    }

    override public func loadView() {
        var screen = SearchScreen(frame: UIScreen.mainScreen().bounds)
        self.view = screen
        screen.delegate = self
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        streamViewController.pullToRefreshEnabled = false
        updateInsets()
    }

    override func viewForStream() -> UIView {
        return screen.viewForStream()
    }

    override func showNavBars(scrollToBottom : Bool) {
    }

    override func hideNavBars() {
    }

    private func updateInsets() {
        streamViewController.contentInset.bottom = ElloTabBar.Size.height
        screen.updateInsets(bottom: ElloTabBar.Size.height)
    }

}

extension SearchViewController: SearchScreenDelegate {

    public func searchCanceled() {
        navigationController?.popViewControllerAnimated(true)
    }

    public func searchFieldCleared() {
        userSearchText = ""
        streamViewController.removeAllCellItems()
        streamViewController.cancelInitialPage()
    }

    public func searchFieldChanged(text: String) {
        if count(text) < 2 { return }  // just.. no (and the server doesn't guard against empty/short searches)
        if userSearchText == text { return }  // a search is already in progress for this text
        userSearchText = text

        let endpoint = ElloAPI.SearchForUsers(terms: text)
        streamViewController.streamKind = .UserList(endpoint: endpoint, title: "")
        streamViewController.removeAllCellItems()
        ElloHUD.showLoadingHudInView(streamViewController.view)
        streamViewController.loadInitialPage()
    }

    public func findFriendsTapped() {
        let responder = targetForAction("onInviteFriends", withSender: self) as? InviteResponder
        responder?.onInviteFriends()
    }

}
