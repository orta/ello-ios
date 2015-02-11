//
//  NotificationsViewController.swift
//  Ello
//
//  Created by Sean Dougherty on 11/20/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//


import UIKit
import WebKit

class NotificationsViewController: StreamableViewController {

    @IBOutlet var containerView : UIView! = nil
    var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true

        setupStreamController()
    }

    private func setupStreamController() {
        let controller = StreamViewController.instantiateFromStoryboard()
        controller.streamKind = .Notifications
        controller.postTappedDelegate = self

        let streamService = StreamService()
        streamService.loadStream(StreamKind.Notifications.endpoint,
            success: { (streamables) -> () in
                controller.addStreamables(streamables)
                controller.doneLoading()
            },
            failure: { (error, statusCode) -> () in
                println("failed to load notifications (reason: \(error))")
                controller.doneLoading()
            }
        )

        controller.willMoveToParentViewController(self)
        self.view.addSubview(controller.view)
        self.addChildViewController(controller)
    }

}
