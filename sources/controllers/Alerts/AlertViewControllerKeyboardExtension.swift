//
//  AlertViewControllerKeyboardExtension.swift
//  Ello
//
//  Created by Sean on 2/2/16.
//  Copyright © 2016 Ello. All rights reserved.
//

import Foundation

public extension AlertViewController {

    func keyboardUpdateFrame(keyboard: Keyboard) {
        let availHeight = UIWindow.mainWindow.frame.height - (Keyboard.shared().active ? Keyboard.shared().endFrame.height : 0)
        let top = max(15, (availHeight - view.frame.height) / 2)
        animate(duration: Keyboard.shared().duration) {
            self.view.frame.origin.y = top

            let bottomInset = Keyboard.shared().keyboardBottomInset(inView: self.tableView)
            self.tableView.contentInset.bottom = bottomInset
            self.tableView.scrollIndicatorInsets.bottom = bottomInset
            self.tableView.scrollEnabled = (bottomInset > 0 || self.view.frame.height == MaxHeight)
        }
    }
}
