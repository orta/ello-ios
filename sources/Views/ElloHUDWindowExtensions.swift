//
//  ElloHUDWindowExtensions.swift
//  Ello
//
//  Created by Sean on 2/4/16.
//  Copyright © 2016 Ello. All rights reserved.
//

import MBProgressHUD

extension ElloHUD {

    class func showLoadingHud() -> MBProgressHUD? {
        if let win = UIApplication.sharedApplication().windows.last {
            return ElloHUD.showLoadingHudInView(win)
        }
        else {
            return nil
        }
    }

    class func hideLoadingHud() {
        if let win = UIApplication.sharedApplication().windows.last {
            ElloHUD.hideLoadingHudInView(win)
        }
    }
}
