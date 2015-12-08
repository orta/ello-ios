//
//  DebugTodoController.swift
//  Ello
//
//  Created by Colin Gray on 8/14/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

#if DEBUG

import SVGKit
import SwiftyUserDefaults
import Firebase
import Crashlytics

struct DebugTodo {
    var id: String
    var name: String
    var group: String
    var url: String
    var done: Int
}

let debugGroups = ["New Features", "Intro", "Signup", "Onboarding", "Streams", "Profile", "Posting", "Other"]

class DebugTodoController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var todoListRef: Firebase?
    let tableView = UITableView()
    var entries = [DebugTodo]()
    var actions = [(String, BasicBlock)]()

    private func addAction(name: String, block: BasicBlock) {
        actions.append((name, block))
    }

    var marketingVersion = ""
    var buildVersion = ""

    override func viewDidLoad() {
        if let version = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String {
            marketingVersion = version.stringByReplacingOccurrencesOfString(".", withString: "-", options: [], range: nil)
        }

        if let bundleVersion = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String {
            buildVersion = bundleVersion.stringByReplacingOccurrencesOfString(".", withString: "-", options: [], range: nil)
        }

        let appController = UIApplication.sharedApplication().keyWindow!.rootViewController as! AppViewController
        addAction("Logout") {
            appController.dismissViewControllerAnimated(false, completion: nil)
            delay(0.1) {
                appController.userLoggedOut()
            }
        }
        addAction("Reset Tab bar Tooltips") {
            Defaults[ElloTab.Discovery.narrationDefaultKey] = nil
            Defaults[ElloTab.Notifications.narrationDefaultKey] = nil
            Defaults[ElloTab.Stream.narrationDefaultKey] = nil
            Defaults[ElloTab.Profile.narrationDefaultKey] = nil
            Defaults[ElloTab.Post.narrationDefaultKey] = nil
        }
        addAction("Reset Intro") {
            Defaults["IntroDisplayed"] = nil
        }
        addAction("Reset Onboarding") {
            Onboarding.shared().reset()
        }
        addAction("Crash the app") {
            Crashlytics.sharedInstance().crash()
        }

        addAction("Debug Views") { [unowned self] in
            let vc = DebugViewsController()
            self.navigationController?.pushViewController(vc, animated: true)
        }

        addAction("Show Rate Prompt") {
            Rate.sharedRate.prompt()
        }

        addAction("Show Push Notification Alert") {
            PushNotificationController.sharedController.permissionDenied = false
            PushNotificationController.sharedController.needsPermission = true
            if let alert = PushNotificationController.sharedController.requestPushAccessIfNeeded() {
                appController.dismissViewControllerAnimated(false, completion: nil)
                delay(0.1) {
                    appController.presentViewController(alert, animated: true, completion: .None)
                }
            }
        }

        tableView.frame = view.bounds
        tableView.delegate = self
        tableView.dataSource = self
        tableView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "todo")
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "loading")
        view.addSubview(tableView)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        let root = Firebase(url: "https://elloios.firebaseio.com")
        let todoListRef = root.childByAppendingPath("list")
        self.todoListRef = todoListRef

        todoListRef.observeEventType(.Value, withBlock: { snapshot in
            self.entries = [DebugTodo]()
            if let values = snapshot.value as? [String: [String: AnyObject]] {

                for (id, entryValue) in values {
                    if let name = entryValue["name"] as? String {
                        let group = entryValue["group"] as? String ?? debugGroups.last ?? ""
                        var entry = DebugTodo(id: id, name: name, group: group, url: "list/\(id)/v\(self.marketingVersion)/b\(self.buildVersion)", done: 0)

                        if let version = entryValue["v\(self.marketingVersion)"] as? [String: AnyObject],
                            doneCount = version["b\(self.buildVersion)"] as? Int {
                                entry.done = doneCount
                        }
                        self.entries.append(entry)
                    }
                }
            }

            self.entries.sortInPlace { $0.id < $1.id }
            self.tableView.reloadData()
        })
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if let ref = todoListRef {
            ref.removeAllObservers()
            todoListRef = nil
        }
    }

    func addTodoItem() {
        let alertController = AlertViewController()
        for group in debugGroups {
            let action = AlertAction(title: group, style: .Light, handler: { _ in self.addTodoItemInGroup(group) })
            alertController.addAction(action)
        }
        let action = AlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .Dark, handler: nil)
        alertController.addAction(action)

        presentViewController(alertController, animated: true, completion: nil)
    }

    func addTodoItemInGroup(group: String) {
        let ctlr = UIAlertController(title: "Name:", message: "", preferredStyle: .Alert)
        ctlr.addTextFieldWithConfigurationHandler() { textField in
            textField.autocapitalizationType = .Sentences
            textField.autocorrectionType = .Default
            textField.spellCheckingType = .Default
            textField.placeholder = "Name"
        }
        let done = UIAlertAction(title: NSLocalizedString("Done", comment: "Done"), style: .Default, handler: { action in
            if let field = ctlr.textFields?.safeValue(0),
                text = field.text,
                ref = self.todoListRef?.childByAutoId()
            where text.characters.count > 0 {
                let val = ["name": text, "group": group]
                ref.setValue(val)
            }
        })
        ctlr.addAction(done)
        presentViewController(ctlr, animated: true, completion: nil)
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if entries.count == 0 {
            return 2
        }
        else {
            return 1 + debugGroups.count
        }
    }

    func groupForSection(section: Int) -> String? {
        return debugGroups.safeValue(section)
    }

    func todosInGroup(group: String) -> [DebugTodo] {
        return self.entries.filter { $0.group == group }
    }

    var actionsSection: Int {
        if entries.count == 0 {
            return 1
        }
        return debugGroups.count
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == actionsSection {
            return actions.count
        }

        if entries.count == 0 {
            return 1
        }

        if let group = groupForSection(section) {
            return todosInGroup(group).count
        }

        return 0
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if entries.count == 0 {
            return nil
        }
        else if section == actionsSection {
            return "Debugging Actions"
        }

        if let group = groupForSection(section) where todosInGroup(group).count > 0 {
            return group
        }

        return nil
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath path: NSIndexPath) -> UITableViewCell {
        if path.section == actionsSection {
            let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Action")
            if let label = cell.textLabel, action = actions.safeValue(path.row) {
                label.font = UIFont.defaultBoldFont()
                label.text = action.0
            }
            return cell
        }

        if entries.count == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("loading")
            if let label = cell?.textLabel {
                label.font = UIFont.defaultBoldFont()
                label.text = "Loading…"
            }
            return cell ?? UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Action")
        }

        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "todo")
        if let group = groupForSection(path.section) {
            let groupEntries = todosInGroup(group)
            if let entry = groupEntries.safeValue(path.row), label = cell.textLabel, details = cell.detailTextLabel {
                label.font = UIFont.defaultFont()
                label.text = entry.name
                details.textColor = UIColor.greyA()
                details.text = "Checked: \(entry.done)"
            }
        }
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath path: NSIndexPath) {
        tableView.deselectRowAtIndexPath(path, animated: true)
        if path.section == actionsSection {
            if let action = actions.safeValue(path.row) {
                action.1()
            }
        }

        if entries.count == 0 {
            return
        }

        if let group = groupForSection(path.section) {
            let groupEntries = todosInGroup(group)
            if let entry = groupEntries.safeValue(path.row) {
                let root = Firebase(url: "https://elloios.firebaseio.com")
                let doneRef = root.childByAppendingPath(entry.url)
                doneRef.setValue(entry.done + 1)
            }
        }
    }

}
#endif
