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
import ImagePickerSheetController

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
        addAction("ImagePickerSheetController") {
            let controller = ImagePickerSheetController(mediaType: .ImageAndVideo)
            controller.addAction(ImagePickerAction(title: NSLocalizedString("Take Photo Or Video", comment: "Action Title"), secondaryTitle: NSLocalizedString("Add comment", comment: "Action Title"), handler: { _ in
                // presentImagePickerController(.Camera)
                print("=============== \(__FILE__) line \(__LINE__) ===============")
            }, secondaryHandler: { _, numberOfPhotos in
                print("Comment \(numberOfPhotos) photos")
            }))
            controller.addAction(ImagePickerAction(title: NSLocalizedString("Photo Library", comment: "Action Title"), secondaryTitle: { NSString.localizedStringWithFormat(NSLocalizedString("ImagePickerSheet.button1.Send %lu Photo", comment: "Action Title"), $0) as String}, handler: { _ in
                // presentImagePickerController(.PhotoLibrary)
                print("=============== \(__FILE__) line \(__LINE__) ===============")
            }, secondaryHandler: { _, numberOfPhotos in
                print("Send \(controller.selectedImageAssets)")
            }))
            controller.addAction(ImagePickerAction(title: NSLocalizedString("Cancel", comment: "Action Title"), style: .Cancel, handler: { _ in
                print("Cancelled")
            }))

            self.presentViewController(controller, animated: true, completion: nil)
        }
        addAction("Invalidate refresh token (use user credentials)") {
            var token = AuthToken()
            token.token = "nil"
            token.refreshToken = "nil"
            appController.closeTodoController()

            let profileService = ProfileService()
            profileService.loadCurrentUser(success: { _ in }, failure: { _ in })
            profileService.loadCurrentUser(success: { _ in }, failure: { _ in })
            nextTick {
                profileService.loadCurrentUser(success: { _ in }, failure: { _ in })
            }
        }
        addAction("Invalidate token completely (logout)") {
            var token = AuthToken()
            token.token = "nil"
            token.refreshToken = "nil"
            token.username = "ello@ello.co"
            token.password = "this is definitely NOT my password"
            appController.closeTodoController()

            let profileService = ProfileService()
            profileService.loadCurrentUser(success: { _ in print("success 1") }, failure: { _ in print("failure 1") })
            profileService.loadCurrentUser(success: { _ in print("success 2") }, failure: { _ in print("failure 2") })
            nextTick {
                profileService.loadCurrentUser(success: { _ in print("success 3") }, failure: { _ in print("failure 3") })
            }
        }
        addAction("Reset Tab bar Tooltips") {
            GroupDefaults[ElloTab.Discovery.narrationDefaultKey] = nil
            GroupDefaults[ElloTab.Notifications.narrationDefaultKey] = nil
            GroupDefaults[ElloTab.Stream.narrationDefaultKey] = nil
            GroupDefaults[ElloTab.Profile.narrationDefaultKey] = nil
            GroupDefaults[ElloTab.Post.narrationDefaultKey] = nil
        }
        addAction("Reset Intro") {
            GroupDefaults["IntroDisplayed"] = nil
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
