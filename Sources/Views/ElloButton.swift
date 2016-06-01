//
//  ElloButton.swift
//  Ello
//
//  Created by Sean Dougherty on 11/24/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit

public class ElloButton: UIButton {

    override public var enabled: Bool {
        didSet { updateStyle() }
    }

    override public var selected: Bool {
        didSet { updateStyle() }
    }

    func updateStyle() {
        backgroundColor = enabled ? .blackColor() : .grey231F20()
    }

    required override public init(frame: CGRect) {
        super.init(frame: frame)
        sharedSetup()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedSetup()
    }

    public override func awakeFromNib() {
        super.awakeFromNib()

        if buttonType != .Custom {
            print("Warning, ElloButton instance '\(currentTitle)' should be configured as 'Custom', not \(buttonType)")
        }

        updateStyle()
    }

    func sharedSetup() {
        titleLabel?.font = UIFont.defaultFont()
        titleLabel?.numberOfLines = 1
        setTitleColor(.whiteColor(), forState: .Normal)
        setTitleColor(.greyA(), forState: .Disabled)
        updateStyle()
    }

    public override func titleRectForContentRect(contentRect: CGRect) -> CGRect {
        var titleRect = super.titleRectForContentRect(contentRect)
        let delta: CGFloat = 4
        titleRect.size.height += 2 * delta
        titleRect.origin.y -= delta
        return titleRect
    }

}

public class LightElloButton: ElloButton {

    override func updateStyle() {
        backgroundColor = enabled ? .greyE5() : .greyF1()
    }

    override func sharedSetup() {
        titleLabel?.font = UIFont.defaultFont()
        titleLabel?.numberOfLines = 1
        setTitleColor(.grey6(), forState: .Normal)
        setTitleColor(.blackColor(), forState: .Highlighted)
        setTitleColor(.greyC(), forState: .Disabled)
    }

}

public class WhiteElloButton: ElloButton {

    required public init(frame: CGRect) {
        super.init(frame: frame)
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func updateStyle() {
        if !enabled {
            backgroundColor = .greyA()
        }
        else if selected {
            backgroundColor = .blackColor()
        }
        else {
            backgroundColor = .whiteColor()
        }
    }

    override func sharedSetup() {
        super.sharedSetup()
        titleLabel?.font = UIFont.defaultFont()
        setTitleColor(.blackColor(), forState: .Normal)
        setTitleColor(.grey6(), forState: .Highlighted)
        setTitleColor(.greyC(), forState: .Disabled)
        setTitleColor(.whiteColor(), forState: .Selected)
    }
}

public class OutlineElloButton: WhiteElloButton {

    override func sharedSetup() {
        super.sharedSetup()
        backgroundColor = .whiteColor()
        updateOutline()
    }

    override public var highlighted: Bool {
        didSet {
            updateOutline()
        }
    }

    private func updateOutline() {
        layer.borderColor = highlighted ? UIColor.greyE5().CGColor : UIColor.blackColor().CGColor
        layer.borderWidth = 1
    }
}


public class RoundedElloButton: ElloButton {
    var borderColor: UIColor = .blackColor() {
        didSet {
            updateOutline()
        }
    }

    override public func sharedSetup() {
        super.sharedSetup()
        setTitleColor(.blackColor(), forState: .Normal)
        setTitleColor(.grey6(), forState: .Highlighted)
        setTitleColor(.greyC(), forState: .Disabled)
        layer.borderWidth = 1
        backgroundColor = .clearColor()
        updateOutline()
    }

    override func updateStyle() {
        backgroundColor = enabled ? .clearColor() : .grey231F20()
    }

    func updateOutline() {
        layer.borderColor = borderColor.CGColor
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = min(frame.height, frame.width) / 2
    }
}

public class GreenElloButton: ElloButton {

    override func updateStyle() {
        backgroundColor = enabled ? .greenD1() : .greyF1()
    }

    override func sharedSetup() {
        titleLabel?.font = UIFont.defaultFont()
        titleLabel?.numberOfLines = 1
        setTitleColor(.whiteColor(), forState: .Normal)
        setTitleColor(.grey6(), forState: .Highlighted)
        setTitleColor(.greyA(), forState: .Disabled)
        layer.cornerRadius = 5
    }

}
