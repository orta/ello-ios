//
//  DrawerViewDataSource.swift
//  Ello
//
//  Created by Gordon Fontenot on 3/16/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public struct DrawerItem {
    public let name: String
    public var link: String?
    public let type: DrawerItemType
}

public enum DrawerItemType {
    case External
    case Invite
    case Logout
    case Version
}

public class DrawerViewDataSource: NSObject {
    lazy var items: [DrawerItem] = {
        return [
            DrawerItem(name: InterfaceString.Drawer.Store, type: .External("http://ello.threadless.com/")),
            DrawerItem(name: InterfaceString.Drawer.Invite, type: .Invite),
            DrawerItem(name: InterfaceString.Drawer.Help, type: .External("https://ello.co/wtf/help/the-basics/")),
            DrawerItem(name: InterfaceString.Drawer.Resources, type: .External("https://ello.co/wtf/resources/community-directory/")),
            DrawerItem(name: InterfaceString.Drawer.About, type: .External("https://ello.co/wtf/about/what-is-ello/")),
            DrawerItem(name: InterfaceString.Drawer.Logout, type: .Logout),
            DrawerItem(name: InterfaceString.Drawer.Version, type: .Version),
        ]
    }()

    public func itemForIndexPath(indexPath: NSIndexPath) -> DrawerItem? {
        return items.safeValue(indexPath.row)
    }
}

// MARK: UITableViewDataSource
extension DrawerViewDataSource: UITableViewDataSource {
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(DrawerCell.reuseIdentifier(), forIndexPath: indexPath) as! DrawerCell
        if let item = items.safeValue(indexPath.row) {
            DrawerCellPresenter.configure(cell, item: item)
        }
        return cell
    }
}
