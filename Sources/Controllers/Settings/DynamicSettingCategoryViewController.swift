//
//  DynamicSettingCategoryViewController.swift
//  Ello
//
//  Created by Tony DiPasquale on 4/13/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

class DynamicSettingCategoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ControllerThatMightHaveTheCurrentUser {
    var category: DynamicSettingCategory?
    var currentUser: User?
    @IBOutlet weak var tableView: UITableView!
    weak var navBar: ElloNavigationBar!

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
        let backItem = UIBarButtonItem.backChevronWithTarget(self, action: Selector("backAction"))
        navigationItem.leftBarButtonItem = backItem
        navigationItem.title = category?.label
        navigationItem.fixNavBarItemPadding()
        navBar.items = [navigationItem]
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Slide)
    }

    func backAction() {
        navigationController?.popViewControllerAnimated(true)
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return category?.settings.count ?? 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
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

extension DynamicSettingCategoryViewController: DynamicSettingCellDelegate {
    func toggleSetting(setting: DynamicSetting, value: Bool) {
        if let nav = self.navigationController as? ElloNavigationController {
            ProfileService().updateUserProfile([setting.key: value],
                success: { user in
                    nav.setProfileData(user)
                    self.tableView.reloadData()
                },
                failure: { (_,_) in
                    self.tableView.reloadData()
                })
        }
    }

    func deleteAccount() {
        let vc = DeleteAccountConfirmationViewController()
        presentViewController(vc, animated: true, completion: .None)
    }
}
