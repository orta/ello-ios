//
//  DynamicSettingsViewController.swift
//  Ello
//
//  Created by Tony DiPasquale on 4/10/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit
import SwiftyJSON

private let DynamicSettingsCellHeight: CGFloat = 50

private enum DynamicSettingsSection: Int {
    case DynamicSettings
    case AccountDeletion
    case Unknown

    static var count: Int {
        return DynamicSettingsSection.Unknown.rawValue
    }
}

class DynamicSettingsViewController: UITableViewController {
    var dynamicCategories: [DynamicSettingCategory] = []
    var currentUser: User?

    var height: CGFloat {
        return DynamicSettingsCellHeight * CGFloat(dynamicCategories.count + 1)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.scrollsToTop = false

        StreamService().loadStream(.ProfileToggles,
            streamKind: nil,
            success: { (data, responseConfig) in
                if let categories = data as? [DynamicSettingCategory] {
                    self.dynamicCategories = categories.reduce([]) { categoryArr, category in
                        category.settings = category.settings.reduce([]) { settingsArr, setting in
                            if self.currentUser?.hasProperty(setting.key) == true {
                                return settingsArr + [setting]
                            }
                            return settingsArr
                        }
                        if category.settings.count > 0 {
                            return categoryArr + [category]
                        }
                        return categoryArr
                    }
                }
                ElloHUD.hideLoadingHud()
            },
            failure: { _, _ in
                ElloHUD.hideLoadingHud()
            },
            noContent: {
                ElloHUD.hideLoadingHud()
            }
        )
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return DynamicSettingsSection.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch DynamicSettingsSection(rawValue: section) ?? .Unknown {
        case .DynamicSettings: return dynamicCategories.count
        case .AccountDeletion: return 1
        case .Unknown: return 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PreferenceCell", forIndexPath: indexPath) 

        switch DynamicSettingsSection(rawValue: indexPath.section) ?? .Unknown {
        case .DynamicSettings:
            let category = dynamicCategories[indexPath.row]
            cell.textLabel?.text = category.label

        case .AccountDeletion:
            cell.textLabel?.text = DynamicSettingCategory.accountDeletionCategory.label

        case .Unknown: break
        }

        return cell
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return DynamicSettingsCellHeight
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "DynamicSettingCategorySegue" {
            let controller = segue.destinationViewController as! DynamicSettingCategoryViewController
            let selectedIndexPath = tableView.indexPathForSelectedRow

            switch DynamicSettingsSection(rawValue: selectedIndexPath?.section ?? 0) ?? .Unknown {
            case .DynamicSettings:
                let index = tableView.indexPathForSelectedRow?.row ?? 0
                controller.category = dynamicCategories[index]

            case .AccountDeletion:
                controller.category = DynamicSettingCategory.accountDeletionCategory

            case .Unknown: break
            }
            controller.currentUser = currentUser
        }
    }
}
