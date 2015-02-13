//
//  NotificationsFilterBar.swift
//  Ello
//
//  Created by Colin Gray on 2/10/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit

class NotificationsFilterBar : UIView {
    var buttons : [UIButton] {
        return self.subviews.filter { $0 as? UIButton != nil } as [UIButton]
    }
    var padding : CGFloat = 1

    override func layoutSubviews() {
        super.layoutSubviews()

        let buttons = self.buttons
        if buttons.count > 0 {
            var x : CGFloat = 0
            var w : CGFloat = (self.frame.size.width - padding * CGFloat(buttons.count - 1)) / CGFloat(buttons.count)
            for button in buttons {
                let frame = CGRect(x: x, y: 0, width: w, height: self.frame.size.height)
                button.frame = frame
                x += w + padding
            }
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
