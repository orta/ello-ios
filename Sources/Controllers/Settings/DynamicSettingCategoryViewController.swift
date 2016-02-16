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

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if  let setting = category?.settings.safeValue(indexPath.row),
            let user = currentUser
        {
            let isVisible = DynamicSettingCellPresenter.isVisible(setting: setting, currentUser: user)
            if !isVisible {
                return 0
            }
        }

        return UITableViewAutomaticDimension
    }
}

extension DynamicSettingCategoryViewController: DynamicSettingCellDelegate {
    func toggleSetting(setting: DynamicSetting, value: Bool) {
        if let nav = self.navigationController as? ElloNavigationController {
            var visibility: [(NSIndexPath, Bool)] = []
            if let settings = self.category?.settings,
                currentUser = currentUser {
                for (index, setting) in settings.enumerate() {
                    visibility.append((NSIndexPath(forRow: index, inSection: 0), DynamicSettingCellPresenter.isVisible(setting: setting, currentUser: currentUser)))
                }
            }

            ProfileService().updateUserProfile([setting.key: value],
                success: { user in
                    nav.setProfileData(user)

                    if let settings = self.category?.settings {
                        var changedPaths: [NSIndexPath] = []
                        for (indexPath, prevVisibility) in visibility {
                            let setting = settings[indexPath.row]
                            if prevVisibility != DynamicSettingCellPresenter.isVisible(setting: setting, currentUser: user) {
                                changedPaths.append(indexPath)
                            }
                        }
                        self.tableView.reloadRowsAtIndexPaths(changedPaths, withRowAnimation: .Automatic)
                    }

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
