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
        var screen = SearchScreen(frame: UIScreen.mainScreen().bounds, isSearchView: true)
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
        streamViewController.noResultsMessages = (title: "", body: "")
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
        // track that a search is going down
        if isPostSearch {
            if text.hasPrefix("#") {
                Tracker.sharedTracker.searchFor("hashtags")
            }
            else {
                Tracker.sharedTracker.searchFor("posts")
            }
        }
        else {
            Tracker.sharedTracker.searchFor("users")
        }
        searchText = text
        let endpoint = isPostSearch ? ElloAPI.SearchForPosts(terms: text) : ElloAPI.SearchForUsers(terms: text)
        streamViewController.noResultsMessages = (title: NSLocalizedString("We couldn't find any matches.", comment: "No search results found title"), body: NSLocalizedString("Try another search?", comment: "No search results found body"))
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
