//
//  SearchViewController.swift
//  Ello
//
//  Created by Colin Gray on 4/21/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public class SearchViewController: StreamableViewController {
    var searchText: String?

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
        searchText = ""
        streamViewController.removeAllCellItems()
        streamViewController.cancelInitialPage()
        streamViewController.noResultsMessages = (title: NSLocalizedString("", comment: ""), body: NSLocalizedString("", comment: ""))
    }

    public func searchFieldChanged(text: String, isPostSearch: Bool) {
        loadEndpoint(text, isPostSearch: isPostSearch)
    }

    public func toggleChanged(text: String, isPostSearch: Bool) {
        loadEndpoint(text, isPostSearch: isPostSearch, checkSearchText: false)
    }

    private func loadEndpoint(text: String, isPostSearch: Bool, checkSearchText: Bool = true) {
        if count(text) < 2 { return }  // just.. no (and the server doesn't guard against empty/short searches)
        if checkSearchText && searchText == text { return }  // a search is already in progress for this text
        searchText = text
        let endpoint: ElloAPI
        if isPostSearch {
            endpoint = ElloAPI.SearchForPosts(terms: text)
            streamViewController.noResultsMessages = (title: NSLocalizedString("No posts found.", comment: "No posts found title"), body: NSLocalizedString("We couldn't find any posts that matched \"\(text)\".", comment: "No posts found body"))
        }
        else {
            endpoint = ElloAPI.SearchForUsers(terms: text)
            streamViewController.noResultsMessages = (title: NSLocalizedString("No users found.", comment: "No people found title"), body: NSLocalizedString("We couldn't find any users that matched \"\(text)\".", comment: "No people found body"))
        }
        streamViewController.hideNoResults()
        streamViewController.streamKind = .SimpleStream(endpoint: endpoint, title: "")
        streamViewController.removeAllCellItems()
        ElloHUD.showLoadingHudInView(streamViewController.view)
        streamViewController.loadInitialPage()
    }

    public func findFriendsTapped() {
        let responder = targetForAction("onInviteFriends", withSender: self) as? InviteResponder
        responder?.onInviteFriends()
    }

}
