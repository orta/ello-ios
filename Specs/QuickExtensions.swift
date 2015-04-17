//
//  QuickExtensions.swift
//  Ello
//
//  Created by Colin Gray on 4/17/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//
import Quick


extension QuickSpec {

    func showController(viewController: UIViewController) -> UIWindow {
        let window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window.makeKeyAndVisible()
        window.rootViewController = viewController
        return window
    }
}
