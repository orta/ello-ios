//
//  NotificationsFilterBar.swift
//  Ello
//
//  Created by Colin Gray on 2/10/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit

class NotificationsFilterBar : UIView {
    var buttons : [UIButton] = [] {
        willSet(newButtons) { removeAllButtons() }
        didSet { addButtonViews(buttons) }
    }
    var padding : CGFloat = 1

    override func layoutSubviews() {
        super.layoutSubviews()

        let buttons = self.subviews.filter { $0 as? UIButton != nil }
        if let buttons = buttons as? [UIButton] {
            if buttons.count > 0 {
                var x : CGFloat = 0
                var w : CGFloat = (self.frame.size.width - padding * CGFloat(buttons.count - 1)) / CGFloat(buttons.count)
                for button : UIButton in self.subviews {
                    button.frame = CGRect(x: x, y: 0, width: w, height: self.frame.size.height)
                    x += w + padding
                }
            }
        }
    }

    func addButton(button : UIButton) {
        self.addSubview(button)
    }

    private func removeAllButtons() {
        for b in self.buttons {
            b.removeFromSuperview()
        }
    }

    private func addButtonViews(newButtons : [UIButton]) {
        for b in newButtons {
            self.addSubview(b)
        }
    }

    func selectButton(selectedButton : UIButton) {
        for button in buttons {
            button.selected = button == selectedButton
        }
    }

}
