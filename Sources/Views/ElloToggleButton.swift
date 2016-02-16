//
//  ElloToggleButton.swift
//  Ello
//
//  Created by Tony DiPasquale on 4/13/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public class ElloToggleButton: UIButton {
    private let attributes = [NSFontAttributeName: UIFont.defaultFont()]

    public var text: String? {
        didSet {
            toggleButton()
        }
    }
    public var value: Bool = false {
        didSet {
            toggleButton()
        }
    }
    override public var enabled: Bool {
        didSet {
            toggleButton()
        }
    }

    override public func awakeFromNib() {
        super.awakeFromNib()
        layer.borderWidth = 1

        toggleButton()
    }

    public func setText(text: String, color: UIColor) {
        let string = NSMutableAttributedString(string: text, attributes: attributes)
        string.addAttribute(NSForegroundColorAttributeName, value: color, range: NSRange(location: 0, length: string.length))
        setAttributedTitle(string, forState: .Normal)
    }

    private func toggleButton() {
        let highlightedColor: UIColor = enabled ? .greyA() : .greyC()
        let offColor: UIColor = .whiteColor()

        layer.borderColor = highlightedColor.CGColor
        backgroundColor = value ? highlightedColor : offColor
        let text = self.text ?? (value ? "Yes" : "No")
        setText(text, color: value ? offColor : highlightedColor)
    }
}
