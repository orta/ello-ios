//
//  SearchViewController.swift
//  Ello
//
//  Created by Colin Gray on 4/21/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public class SearchViewController: BaseElloViewController {
    var userSearchText: String?
    var streamViewController: StreamViewController!

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
        setupStreamViewController()
        self.screen.insertStreamView(streamViewController.view)
    }

    private func setupStreamViewController() {
        streamViewController = StreamViewController.instantiateFromStoryboard()
        streamViewController.currentUser = currentUser

        streamViewController.userTappedDelegate = self

        streamViewController.willMoveToParentViewController(self)
        self.addChildViewController(streamViewController)
        streamViewController.didMoveToParentViewController(self)
    }

}

// MARK: UserTappedDelegate
extension SearchViewController: UserTappedDelegate {
    public func userTapped(user: User) {
        let vc = ProfileViewController(userParam: user.id)
        vc.currentUser = currentUser
        vc.willPresentStreamable(true)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension SearchViewController: SearchScreenDelegate {

    public func searchCanceled() {
        navigationController?.popViewControllerAnimated(true)
    }

    public func searchFieldCleared() {
        userSearchText = ""
        streamViewController.removeRefreshables()
        streamViewController.cancelInitialPage()
    }

    public func searchFieldChanged(text: String) {
        if count(text) < 2 { return }  // just.. no (and the server doesn't guard against empty/short searches)
        if userSearchText == text { return }  // a search is already in progress for this text
        userSearchText = text

        let endpoint = ElloAPI.SearchForUsers(terms: text)
        streamViewController.streamKind = .UserList(endpoint: endpoint, title: "")
        streamViewController.removeRefreshables()
        streamViewController.loadInitialPage()
    }

}
