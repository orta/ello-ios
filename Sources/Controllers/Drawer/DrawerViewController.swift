//
//  DrawerViewController.swift
//  Ello
//
//  Created by Gordon Fontenot on 3/5/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation
import SVGKit
import Crashlytics

public class DrawerViewController: StreamableViewController {
    @IBOutlet weak public var tableView: UITableView!
    weak public var navigationBar: ElloNavigationBar!

    override var backGestureEdges: UIRectEdge { return .Right }

    public let dataSource = DrawerViewDataSource()

    required public init() {
        super.init(nibName: "DrawerViewController", bundle: .None)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Using a StreamableViewController to gain access to the InviteResponder
    // Not a great longterm setup.
    override func setupStreamController() {
        // noop
    }
}

// MARK: View Lifecycle
extension DrawerViewController {
    override public func viewDidLoad() {
        addHamburgerButton()
        addLeftButtons()
        setupNavigationBar()
        registerCells()
        super.viewDidLoad()
    }

    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Slide)
        tableView.delegate = self
        tableView.dataSource = dataSource
    }

    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        Crashlytics.sharedInstance().setObjectValue("Drawer", forKey: CrashlyticsKey.StreamName.rawValue)
    }
}

// MARK: Actions
extension DrawerViewController {

    func hamburgerButtonTapped() {
        Tracker.sharedTracker.drawerClosed()
        navigationController?.popViewControllerAnimated(true)
    }

    @IBAction func elloTapped() {
        // no op
    }
}


// MARK: UITableViewDelegate
extension DrawerViewController: UITableViewDelegate {
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let item = dataSource.itemForIndexPath(indexPath) {
            switch item.type {
            case .External:
                if let link = item.link {
                    postNotification(externalWebNotification, value: link)
                }
            case .Invite:
                let responder = targetForAction("onInviteFriends", withSender: self) as? InviteResponder
                responder?.onInviteFriends()
            case .Logout:
                postNotification(AuthenticationNotifications.userLoggedOut, value: ())
            default: break
            }
        }
    }
}


// MARK: View Helpers
private extension DrawerViewController {
    func setupNavigationBar() {
        navigationBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: ElloNavigationBar.Size.height)
        navigationBar.items = [elloNavigationItem]
        navigationBar.tintColor = UIColor.greyA()
    }

    func addLeftButtons() {
        let logoView = UIImageView(image: SVGKImage(named: "ello_logo.svg").UIImage!)
        logoView.frame = CGRect(x: 15, y: 30, width: 24, height: 24)
        navigationBar.addSubview(logoView)
    }

    func addHamburgerButton() {
        let button = UIBarButtonItem(image: SVGKImage(named: "burger_normal.svg").UIImage!, style: .Done, target: self, action: Selector("hamburgerButtonTapped"))
        elloNavigationItem.rightBarButtonItems = [button]
    }

    func registerCells() {
        tableView.registerNib(DrawerCell.nib(), forCellReuseIdentifier: DrawerCell.reuseIdentifier())
    }
}
