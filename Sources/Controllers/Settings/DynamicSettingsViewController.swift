//
//  DynamicSettingsViewController.swift
//  Ello
//
//  Created by Tony DiPasquale on 4/10/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

private let DynamicSettingsCellHeight: CGFloat = 50

private enum DynamicSettingsSection: Int {
    case DynamicSettings
    case Blocked
    case Muted
    case AccountDeletion
    case Unknown

    static var count: Int {
        return DynamicSettingsSection.Unknown.rawValue
    }
}

class DynamicSettingsViewController: UITableViewController {
    var hasMuted = false
    var hasBlocked = false
    var dynamicCategories: [DynamicSettingCategory] = []
    var currentUser: User?
    var hideLoadingHud: BasicBlock = ElloHUD.hideLoadingHud

    var height: CGFloat {
        var totalRows = 0
        for section in 0..<tableView.numberOfSections {
            totalRows += tableView.numberOfRowsInSection(section)
        }
        return DynamicSettingsCellHeight * CGFloat(totalRows)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.scrollsToTop = false
        tableView.rowHeight = DynamicSettingsCellHeight

        hasMuted = (currentUser?.profile?.mutedCount ?? 0) > 0
        hasBlocked = (currentUser?.profile?.blockedCount ?? 0) > 0
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

                    self.reloadTables()
                }
                self.hideLoadingHud()
            },
            failure: { _, _ in
                self.hideLoadingHud()
            },
            noContent: {
                self.hideLoadingHud()
            }
        )
    }

    override func viewDidAppear(animated: Bool) {
        super.viewWillAppear(animated)
        hasMuted = (currentUser?.profile?.mutedCount ?? 0) > 0
        hasBlocked = (currentUser?.profile?.blockedCount ?? 0) > 0
        reloadTables()
    }

    private func reloadTables() {
        self.tableView.reloadData()
        (self.parentViewController as? SettingsViewController)?.tableView.reloadData()
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return DynamicSettingsSection.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch DynamicSettingsSection(rawValue: section) ?? .Unknown {
        case .DynamicSettings: return dynamicCategories.count
        case .Blocked: return hasBlocked ? 1 : 0
        case .Muted: return hasMuted ? 1 : 0
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

        case .Blocked:
            cell.textLabel?.text = DynamicSettingCategory.blockedCategory.label

        case .Muted:
            cell.textLabel?.text = DynamicSettingCategory.mutedCategory.label

        case .AccountDeletion:
            cell.textLabel?.text = DynamicSettingCategory.accountDeletionCategory.label

        case .Unknown: break
        }

        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch DynamicSettingsSection(rawValue: indexPath.section) ?? .Unknown {
        case .DynamicSettings, .AccountDeletion:
            performSegueWithIdentifier("DynamicSettingCategorySegue", sender: nil)
        case .Blocked:
            if let currentUser = currentUser {
                let controller = SimpleStreamViewController(endpoint: .CurrentUserBlockedList, title: "Blocked")
                controller.currentUser = currentUser
                navigationController?.pushViewController(controller, animated: true)
            }
        case .Muted:
            if let currentUser = currentUser {
                let controller = SimpleStreamViewController(endpoint: .CurrentUserMutedList, title: "Muted")
                controller.currentUser = currentUser
                navigationController?.pushViewController(controller, animated: true)
            }
        case .Unknown: break
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "DynamicSettingCategorySegue" {
            let controller = segue.destinationViewController as! DynamicSettingCategoryViewController
            let selectedIndexPath = tableView.indexPathForSelectedRow

            switch DynamicSettingsSection(rawValue: selectedIndexPath?.section ?? 0) ?? .Unknown {
            case .DynamicSettings:
                let index = tableView.indexPathForSelectedRow?.row ?? 0
                controller.category = dynamicCategories[index]

            case .Blocked:
                controller.category = DynamicSettingCategory.blockedCategory

            case .Muted:
                controller.category = DynamicSettingCategory.mutedCategory

            case .AccountDeletion:
                controller.category = DynamicSettingCategory.accountDeletionCategory

            case .Unknown: break
            }
            controller.currentUser = currentUser
        }
    }
}
