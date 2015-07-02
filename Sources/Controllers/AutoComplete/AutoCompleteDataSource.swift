//
//  AutoCompleteDataSource.swift
//  Ello
//
//  Created by Sean on 6/29/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public struct AutoCompleteItem {
    public let result: AutoCompleteResult
    public let type: AutoCompmleteType
}

public enum AutoCompmleteType: String {
    case Emoji = "Emoji"
    case Username = "Username"
}

public class AutoCompleteDataSource: NSObject {

    public var items: [AutoCompleteItem] = []

    public func itemForIndexPath(indexPath: NSIndexPath) -> AutoCompleteItem? {
        return items.safeValue(indexPath.row)
    }
}

// MARK: UITableViewDataSource
extension AutoCompleteDataSource: UITableViewDataSource {
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return count(items)
    }

    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(AutoCompleteCell.reuseIdentifier(), forIndexPath: indexPath) as! AutoCompleteCell
        if let item = items.safeValue(indexPath.row) {
            AutoCompleteCellPresenter.configure(cell, item: item)
        }
        return cell
    }
}
