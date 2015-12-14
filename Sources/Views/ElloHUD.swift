//
//  ElloHUD.swift
//  Ello
//
//  Created by Sean Dougherty on 11/26/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import MBProgressHUD

class ElloHUD: NSObject {

    class func showLoadingHudInView(view: UIView) -> MBProgressHUD? {
        var existingHub: MBProgressHUD?
        for subview in view.subviews {
            if let found = subview as? MBProgressHUD {
                existingHub = found
                break
            }
        }
        if let existingHub = existingHub {
            return existingHub
        }

        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        hud.opacity = 0.0

        let elloLogo = UIImageView(image: Interface.Image.ElloLogo.normalImage)
        elloLogo.bounds = CGRectMake(0, 0, 60, 60)

        let rotate = CABasicAnimation(keyPath: "transform.rotation")
        rotate.fromValue = 0.0
        rotate.toValue = 2 * M_PI
        rotate.duration = 0.35
        rotate.repeatCount = 1_000_000
        elloLogo.layer.addAnimation(rotate, forKey: "10")

        hud.customView = elloLogo
        hud.mode = MBProgressHUDMode.CustomView
        hud.removeFromSuperViewOnHide = true
        return hud
    }

    class func showLoadingHud() -> MBProgressHUD? {
        if let win = UIApplication.sharedApplication().windows.last {
            return ElloHUD.showLoadingHudInView(win)
        }
        else {
            return nil
        }
    }

    class func hideLoadingHudInView(view: UIView) {
        MBProgressHUD.hideHUDForView(view, animated: true)
    }

    class func hideLoadingHud() {
        if let win = UIApplication.sharedApplication().windows.last {
            ElloHUD.hideLoadingHudInView(win)
        }
    }
}
