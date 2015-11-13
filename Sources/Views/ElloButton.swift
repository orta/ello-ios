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

    public func updateStyle() {
        self.backgroundColor = enabled ? .blackColor() : .grey231F20()
    }

    required override public init(frame: CGRect) {
        super.init(frame: frame)
        self.sharedSetup()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.sharedSetup()
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        updateStyle()
    }

    func sharedSetup() {
        self.titleLabel?.font = UIFont.typewriterFont(12)
        self.titleLabel?.numberOfLines = 1
        self.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.setTitleColor(UIColor.greyA(), forState: .Disabled)
        updateStyle()
    }

}

public class LightElloButton: ElloButton {

    override public func updateStyle() {
        self.backgroundColor = enabled ? .greyE5() : .greyF1()
    }

    override public func sharedSetup() {
        self.titleLabel?.font = UIFont.typewriterFont(12)
        self.titleLabel?.numberOfLines = 1
        self.setTitleColor(UIColor.grey6(), forState: .Normal)
        self.setTitleColor(UIColor.blackColor(), forState: .Highlighted)
        self.setTitleColor(UIColor.greyC(), forState: .Disabled)
    }

}

public class WhiteElloButton: ElloButton {

    required public init(frame: CGRect) {
        super.init(frame: frame)
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override public func updateStyle() {
        if !enabled {
            self.backgroundColor = .greyA()
        }
        else if selected {
            self.backgroundColor = .blackColor()
        }
        else {
            self.backgroundColor = .whiteColor()
        }
    }

    override public func sharedSetup() {
        super.sharedSetup()
        self.titleLabel?.font = UIFont.typewriterFont(12)
        self.setTitleColor(UIColor.blackColor(), forState: .Normal)
        self.setTitleColor(UIColor.grey6(), forState: .Highlighted)
        self.setTitleColor(UIColor.greyC(), forState: .Disabled)
        self.setTitleColor(UIColor.whiteColor(), forState: .Selected)
    }
}

public class OutlineElloButton: WhiteElloButton {

    override public func sharedSetup() {
        super.sharedSetup()
        self.setTitleColor(UIColor.blackColor(), forState: .Normal)
        self.setTitleColor(UIColor.greyE5(), forState: .Highlighted)
        self.setTitleColor(UIColor.greyC(), forState: .Disabled)
        self.backgroundColor = .whiteColor()
        updateOutline()
    }

    override public var highlighted: Bool {
        didSet {
            updateOutline()
        }
    }

    private func updateOutline() {
        self.layer.borderColor = highlighted ? UIColor.greyE5().CGColor : UIColor.blackColor().CGColor
        self.layer.borderWidth = 1
    }
}

public class ElloPostButton: ElloButton {
    var pencilView: UIImageView!

    override public var highlighted: Bool {
        didSet {
            updateStyle()
        }
    }

    override public func sharedSetup() {
        setTitle(NSLocalizedString("Post", comment: "Post button title"), forState: .Normal)
        titleLabel?.font = UIFont.regularFont(14)
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

    override public func updateStyle() {
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
