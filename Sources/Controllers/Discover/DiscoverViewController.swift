//
//  DiscoverViewController.swift
//  Ello
//
//  Created by Sean Dougherty on 11/20/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

public class DiscoverViewController: StreamableViewController {

    @IBOutlet weak var navigationContainer: UIView!
    weak var navigationBar: ElloNavigationBar!
    @IBOutlet weak var inviteButton: UIButton!
    @IBOutlet weak var chevron: UIImageView!
    @IBOutlet weak var inviteLabel: UILabel!

    override public var tabBarItem: UITabBarItem? {
        get { return UITabBarItem.item(.Sparkles, insets: UIEdgeInsets(top: 8, left: 0, bottom: -8, right: 0)) }
        set { self.tabBarItem = newValue }
    }

    required public init() {
        super.init(nibName: "DiscoverViewController", bundle: nil)
        title = InterfaceString.Discover.Title
        streamViewController.streamKind = .Discover(type: .Recommended, perPage: 10)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        scrollLogic.prevOffset = streamViewController.collectionView.contentOffset
        ElloHUD.showLoadingHudInView(streamViewController.view)
        streamViewController.loadInitialPage()
    }

    private func updateInsets() {
        updateInsets(navBar: navigationContainer, streamController: streamViewController)
    }

    override public func showNavBars(scrollToBottom: Bool) {
        super.showNavBars(scrollToBottom)
        positionNavBar(navigationContainer, visible: true)
        updateInsets()

        if scrollToBottom {
            self.scrollToBottom(streamViewController)
        }
    }

    override public func hideNavBars() {
        super.hideNavBars()
        positionNavBar(navigationContainer, visible: false)
        updateInsets()
    }

    // MARK: - IBActions

    @IBAction func importMyContactsTapped() {
        let responder = targetForAction(#selector(InviteResponder.onInviteFriends), withSender: self) as? InviteResponder
        responder?.onInviteFriends()
    }

    // MARK: - Private

    private func setupNavigationBar() {
        navigationController?.navigationBarHidden = true
        addSearchButton()
        elloNavigationItem.title = title
        navigationBar.items = [elloNavigationItem]
        setupInviteFriendsButton()
    }

    private func setupInviteFriendsButton() {
        chevron.image = InterfaceImage.AngleBracket.whiteImage
        inviteLabel.text = InterfaceString.Friends.FindAndInvite
        inviteLabel.font = UIFont.defaultFont()
        inviteLabel.textColor = .whiteColor()
    }
}
