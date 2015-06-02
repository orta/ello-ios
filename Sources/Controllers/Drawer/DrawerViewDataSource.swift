//
//  DrawerViewDataSource.swift
//  Ello
//
//  Created by Gordon Fontenot on 3/16/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public struct DrawerItem {
    let name: String
    var link: String?
    var closure: ((controller: UIViewController) -> Void)?
    let type: DrawerItemType
}

public enum DrawerItemType {
    case External
    case Internal
    case Plain
}

public class DrawerViewDataSource: NSObject {
    lazy var items: [DrawerItem] = {

        var marketingVersion = ""
        if let version = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String {
            marketingVersion = version
        }

        var buildVersion = ""
        if let bundleVersion = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String {
            buildVersion = bundleVersion
        }

        return [
            DrawerItem(name: NSLocalizedString("Store", comment:"Store"), link: "http://ello.threadless.com/", closure: nil, type: .External),
            DrawerItem(name: NSLocalizedString("Invite", comment:"Invite"), link: nil, closure: { controller in
                let responder = controller.targetForAction("onInviteFriends", withSender: controller) as? InviteResponder
                responder?.onInviteFriends()
            }, type: .Internal),
            DrawerItem(name: NSLocalizedString("Help", comment:"Help"), link: "https://ello.co/wtf/post/help", closure: nil, type: .External),
            DrawerItem(name: NSLocalizedString("Resources", comment:"Resources"), link: "https://ello.co/wtf/post/resources", closure: nil, type: .External),
            DrawerItem(name: NSLocalizedString("About", comment:"About"), link: "https://ello.co/wtf/post/about", closure: nil, type: .External),
            DrawerItem(name: NSLocalizedString("Logout", comment:"Logout"), link: nil, closure: { controller in
                postNotification(AuthenticationNotifications.userLoggedOut, ())
            }, type: .Internal),
            DrawerItem(name: NSLocalizedString("Ello v\(marketingVersion) b\(buildVersion)", comment:"version number"), link: nil, closure: nil, type: .Plain),
        ]
    }()

    public func itemForIndexPath(indexPath: NSIndexPath) -> DrawerItem? {
        return items.safeValue(indexPath.row)
    }
}

// MARK: UITableViewDataSource
extension DrawerViewDataSource: UITableViewDataSource {
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return count(items)
    }

    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(DrawerCell.reuseIdentifier(), forIndexPath: indexPath) as! DrawerCell
        if let item = items.safeValue(indexPath.row) {
            DrawerCellPresenter.configure(cell, item: item)
        }
        return cell
    }
}
