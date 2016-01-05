//
//  DebugTodoController.swift
//  Ello
//
//  Created by Colin Gray on 8/14/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

#if DEBUG

import SwiftyUserDefaults
import Crashlytics

class DebugTodoController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let tableView = UITableView()
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
            appController.closeTodoController()
            delay(0.1) {
                appController.userLoggedOut()
            }
        }
        addAction("Invalidate token") {
            var token = AuthToken()
            token.token = "nil"
            token.refreshToken = "nil"
            appController.closeTodoController()
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

        addAction("Show Notification") {
            appController.closeTodoController()
            delay(0.5) {
                PushNotificationController.sharedController.receivedNotification(UIApplication.sharedApplication(), userInfo: [
                    "application_target": "notifications/posts/6178",
                    "aps": [
                        "alert": ["body": "Hello, Ello!"]
                    ]
                ])
            }
        }

        addAction("Show Rate Prompt") {
            Rate.sharedRate.prompt()
        }

        addAction("Show Push Notification Alert") {
            PushNotificationController.sharedController.permissionDenied = false
            PushNotificationController.sharedController.needsPermission = true
            if let alert = PushNotificationController.sharedController.requestPushAccessIfNeeded() {
                appController.closeTodoController()
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
        view.addSubview(tableView)
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actions.count
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Debugging Actions"
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath path: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Action")
        if let label = cell.textLabel, action = actions.safeValue(path.row) {
            label.font = UIFont.defaultBoldFont()
            label.text = action.0
        }
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath path: NSIndexPath) {
        tableView.deselectRowAtIndexPath(path, animated: true)
        if let action = actions.safeValue(path.row) {
            action.1()
        }
    }

}
#endif
