//
//  DrawerViewController.swift
//  Ello
//
//  Created by Gordon Fontenot on 3/5/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Crashlytics

public class DrawerViewController: StreamableViewController {
    @IBOutlet weak public var tableView: UITableView!
    weak public var navigationBar: ElloNavigationBar!
    public var isLoggingOut = false

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
        super.viewDidLoad()

        addLeftButtons()
        setupTableView()
        setupNavigationBar()
        registerCells()
    }

    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Slide)
    }

    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        Crashlytics.sharedInstance().setObjectValue("Drawer", forKey: CrashlyticsKey.StreamName.rawValue)
    }
}

// MARK: UITableViewDelegate
extension DrawerViewController: UITableViewDelegate {
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let item = dataSource.itemForIndexPath(indexPath) {
            switch item.type {
            case let .External(link):
                postNotification(externalWebNotification, value: link)
            case .Invite:
                let responder = targetForAction("onInviteFriends", withSender: self) as? InviteResponder
                responder?.onInviteFriends()
            case .Logout:
                isLoggingOut = true
                nextTick {
                    self.dismissViewControllerAnimated(true, completion: { _ in
                         postNotification(AuthenticationNotifications.userLoggedOut, value: ())
                    })
                }
            default: break
            }
        }
    }
}

// MARK: View Helpers
private extension DrawerViewController {
    func setupTableView() {
        tableView.backgroundColor = .grey6()
        tableView.delegate = self
        tableView.dataSource = dataSource
    }

    func setupNavigationBar() {
        navigationBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: ElloNavigationBar.Size.height)
        navigationBar.items = [elloNavigationItem]
        navigationBar.tintColor = .greyA()

        let color = UIColor.grey6()
        navigationBar.backgroundColor = color
        navigationBar.shadowImage = nil
        navigationBar.barTintColor = color
    }

    func addLeftButtons() {
        let logoView = UIImageView(image: InterfaceImage.ElloLogo.normalImage)
        logoView.frame = CGRect(x: 15, y: 30, width: 24, height: 24)
        navigationBar.addSubview(logoView)
    }

    func registerCells() {
        tableView.registerNib(DrawerCell.nib(), forCellReuseIdentifier: DrawerCell.reuseIdentifier())
    }
}
