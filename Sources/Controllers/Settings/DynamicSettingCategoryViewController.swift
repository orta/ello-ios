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

    override func viewDidLoad() {
        super.viewDidLoad()

        title = category?.label
        setupTableView()
    }

    private func setupTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
        tableView.registerNib(UINib(nibName: "DynamicSettingCell", bundle: .None), forCellReuseIdentifier: "DynamicSettingCell")
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return category?.settings.count ?? 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DynamicSettingCell", forIndexPath: indexPath) as! DynamicSettingCell
        let setting = category?.settings[indexPath.row]
        setting.map { DynamicSettingCellPresenter.configure(cell, setting: $0) }
        cell.setting = setting
        cell.delegate = self
        return cell
    }
}

extension DynamicSettingCategoryViewController: DynamicSettingCellDelegate {
    func toggleSetting(setting: DynamicSetting) { }
}
