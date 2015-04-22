//
//  DynamicSettingCategoryViewController.swift
//  Ello
//
//  Created by Tony DiPasquale on 4/13/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit


private enum DynamicSettingCategorySection: Int {
    case NavBar
    case Cell
    case Unknown

    static var count: Int {
        return DynamicSettingCategorySection.Unknown.rawValue
    }
}


class DynamicSettingCategoryViewController: UITableViewController, ControllerThatMightHaveTheCurrentUser {
    var category: DynamicSettingCategory?
    var currentUser: User?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = category?.label
        setupTableView()
        setupNavigationBar()
    }

    private func setupTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
        tableView.registerNib(UINib(nibName: "DynamicSettingCell", bundle: .None), forCellReuseIdentifier: "DynamicSettingCell")
    }

    private func setupNavigationBar() {
        let backItem = UIBarButtonItem.backChevronWithTarget(self, action: "backAction")
        navigationItem.leftBarButtonItem = backItem
        navigationItem.title = category?.label
        navigationItem.fixNavBarItemPadding()
    }

    func backAction() {
        navigationController?.popViewControllerAnimated(true)
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return DynamicSettingCategorySection.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch DynamicSettingCategorySection(rawValue: section) ?? .Unknown {
        case .NavBar: return 1
        case .Cell: return category?.settings.count ?? 0
        default: return 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch DynamicSettingCategorySection(rawValue: indexPath.section) ?? .Unknown {
        case .NavBar:
            let cell = UITableViewCell()
            let navBar = ElloNavigationBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: ElloNavigationBar.Size.height))
            navBar.items = [navigationItem]
            cell.contentView.addSubview(navBar)
            return cell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("DynamicSettingCell", forIndexPath: indexPath) as! DynamicSettingCell

            if  let setting = category?.settings.safeValue(indexPath.row),
                let user = currentUser
            {
                DynamicSettingCellPresenter.configure(cell, setting: setting, currentUser: user)
                cell.setting = setting
                cell.delegate = self
            }
            return cell
        }
    }
}

extension DynamicSettingCategoryViewController: DynamicSettingCellDelegate {
    func toggleSetting(setting: DynamicSetting, value: Bool) {
        if let nav = self.navigationController as? ElloNavigationController {
            ProfileService().updateUserProfile([setting.key: value], success: nav.setProfileData) { _, _ in
                self.tableView.reloadData()
            }
        }
    }
}
