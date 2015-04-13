//
//  DynamicSettingCategoryViewController.swift
//  Ello
//
//  Created by Tony DiPasquale on 4/13/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit

class DynamicSettingCategoryViewController: UITableViewController {
    var category: DynamicSettingCategory?
    var currentUser: User?

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return category?.settings.count ?? 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("", forIndexPath: indexPath) as! UITableViewCell
        return cell
    }
}
