//
//  NotificationsFilterBar.swift
//  Ello
//
//  Created by Colin Gray on 2/10/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public class NotificationsFilterBar: UIView {

    struct Size {
        static let height: CGFloat = 64
    }

    var buttons: [UIButton] {
        return self.subviews.filter { $0 as? UIButton != nil } as! [UIButton]
    }
    var buttonPadding: CGFloat = 1

    override public init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .whiteColor()

        let blackBar = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: 20))
        blackBar.autoresizingMask = [.FlexibleWidth, .FlexibleBottomMargin]
        blackBar.backgroundColor = .blackColor()
        self.addSubview(blackBar)
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .whiteColor()
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        let buttons = self.buttons
        if buttons.count > 0 {
            var x: CGFloat = 0
            let y: CGFloat = 20
            let w: CGFloat = (self.frame.size.width - buttonPadding * CGFloat(buttons.count - 1)) / CGFloat(buttons.count)
            for button in buttons {
                let frame = CGRect(x: x, y: y, width: w, height: self.frame.size.height - y)
                button.frame = frame
                x += w + buttonPadding
            }
        }
    }

    public func selectButton(selectedButton: UIButton) {
        for button in buttons {
            button.selected = button == selectedButton
        }
    }
}
