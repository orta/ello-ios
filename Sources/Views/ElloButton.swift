//
//  ElloButton.swift
//  Ello
//
//  Created by Sean Dougherty on 11/24/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit
import SVGKit

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
        setTitleColor(UIColor.whiteColor(), forState: .Normal)
        setTitleColor(UIColor.greyA(), forState: .Disabled)
        updateStyle()
    }

}

public class LightElloButton: ElloButton {

    override func updateStyle() {
        backgroundColor = enabled ? .greyE5() : .greyF1()
    }

    override func sharedSetup() {
        titleLabel?.font = UIFont.defaultFont()
        titleLabel?.numberOfLines = 1
        setTitleColor(UIColor.grey6(), forState: .Normal)
        setTitleColor(UIColor.blackColor(), forState: .Highlighted)
        setTitleColor(UIColor.greyC(), forState: .Disabled)
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
        setTitleColor(UIColor.blackColor(), forState: .Normal)
        setTitleColor(UIColor.grey6(), forState: .Highlighted)
        setTitleColor(UIColor.greyC(), forState: .Disabled)
        setTitleColor(UIColor.whiteColor(), forState: .Selected)
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
    var borderColor: UIColor = UIColor.blackColor() {
        didSet {
            updateOutline()
        }
    }

    override public func sharedSetup() {
        super.sharedSetup()
        setTitleColor(UIColor.blackColor(), forState: .Normal)
        setTitleColor(UIColor.grey6(), forState: .Highlighted)
        setTitleColor(UIColor.greyC(), forState: .Disabled)
        layer.borderWidth = 1
        backgroundColor = UIColor.clearColor()
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

public class ElloPostButton: ElloButton {
    var pencilView: UIImageView!

    override public var highlighted: Bool {
        didSet {
            updateStyle()
        }
    }

    override func sharedSetup() {
        setTitle(NSLocalizedString("Post", comment: "Post button title"), forState: .Normal)
        titleLabel?.font = UIFont.defaultFont()
        setTitleColor(UIColor.whiteColor(), forState: .Normal)
        setTitleColor(UIColor.greyA(), forState: .Highlighted)
        setTitleColor(UIColor.whiteColor(), forState: .Disabled)

        let image = SVGKImage(named: "pencil_white").UIImage!
        pencilView = UIImageView(image: image)
        pencilView.center = bounds.center
        pencilView.autoresizingMask = [.FlexibleRightMargin, .FlexibleTopMargin, .FlexibleBottomMargin]
        addSubview(pencilView)

        updateStyle()
    }

    override func updateStyle() {
        let image = highlighted ? SVGKImage(named: "pencil_normal").UIImage! : SVGKImage(named: "pencil_white").UIImage!
        pencilView.image = image

        backgroundColor = enabled ? .blackColor() : .greyA()
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        pencilView.frame.origin.x = 10
        pencilView.center.y = bounds.size.height / 2
        layer.cornerRadius = min(bounds.size.width, bounds.size.height) / 2
    }

}


public class ElloMentionButton: RoundedElloButton {
    override public func sharedSetup() {
        super.sharedSetup()

        setTitleColor(UIColor.blackColor(), forState: .Normal)
        setTitleColor(UIColor.whiteColor(), forState: .Highlighted)
        setTitleColor(UIColor.greyC(), forState: .Disabled)
    }

    override func updateOutline() {
        super.updateOutline()
        backgroundColor = highlighted ? UIColor.grey4D() : UIColor.whiteColor()
    }
}
