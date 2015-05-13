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
        didSet {
            self.backgroundColor = enabled ? .blackColor() : .grey231F20()
        }
    }

    required override public init(frame: CGRect) {
        super.init(frame: frame)
        self.sharedSetup()
    }

    required public init(coder: NSCoder) {
        super.init(coder: coder)
        self.sharedSetup()
    }

    func sharedSetup() {
        self.titleLabel?.font = UIFont.typewriterFont(14.0)
        self.titleLabel?.numberOfLines = 1
        self.setTitleColor(.whiteColor(), forState: UIControlState.Normal)
        self.setTitleColor(.greyA(), forState: UIControlState.Disabled)
        self.backgroundColor = enabled ? .blackColor() : .grey231F20()
    }

}

public class LightElloButton: ElloButton {

    required public init(frame: CGRect) {
        super.init(frame: frame)
    }

    required public init(coder: NSCoder) {
        super.init(coder: coder)
    }

    override public var enabled: Bool {
        didSet {
            self.backgroundColor = .greyA()
        }
    }

    override public func sharedSetup() {
        self.titleLabel?.font = UIFont.typewriterFont(14.0)
        self.titleLabel?.numberOfLines = 1
        self.setTitleColor(.blackColor(), forState: UIControlState.Normal)
        self.setTitleColor(.blackColor(), forState: UIControlState.Disabled)
        self.backgroundColor = .greyA()
    }

}

public class WhiteElloButton: LightElloButton {

    required public init(frame: CGRect) {
        super.init(frame: frame)
    }

    required public init(coder: NSCoder) {
        super.init(coder: coder)
    }

    override public var enabled: Bool {
        didSet {
            self.backgroundColor = enabled ? .whiteColor() : .greyA()
        }
    }

    override public var selected: Bool {
        didSet {
            self.backgroundColor = selected ? .blackColor() : .whiteColor()
        }
    }

    override public func sharedSetup() {
        super.sharedSetup()
        self.titleLabel?.font = UIFont.typewriterFont(12.0)
        self.setTitleColor(.whiteColor(), forState: UIControlState.Selected)
    }
}
