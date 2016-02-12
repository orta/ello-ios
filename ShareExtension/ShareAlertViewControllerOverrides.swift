//
//  ShareAlertViewControllerOverrides.swift
//  Ello
//
//  Created by Sean on 2/2/16.
//  Copyright © 2016 Ello. All rights reserved.
//

import Foundation

public extension AlertViewController {
    // do not reference anything in the Keyboard
    // App Extensions are prohibited from using
    // some API
    func keyboardUpdateFrame(keyboard: Keyboard) {
    }
}
