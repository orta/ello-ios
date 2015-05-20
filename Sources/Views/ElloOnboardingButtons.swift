//
//  ElloOnboardingButtons.swift
//  Ello
//
//  Created by Colin Gray on 5/20/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public class OnboardingBackButton: UIButton {

    override public var enabled: Bool {
        didSet {
            self.backgroundColor = enabled ? .greyE5() : .greyF1()
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
        self.setSVGImages("abracket", degree: 180.0)
        self.backgroundColor = enabled ? .greyE5() : .greyF1()
    }

}

public class OnboardingNextButton: LightElloButton {
    var chevron: UIImageView?

    override public func sharedSetup() {
        super.sharedSetup()
        titleEdgeInsets.right = 20

        let chevron = UIImageView()
        chevron.autoresizingMask = .FlexibleLeftMargin | .FlexibleTopMargin | .FlexibleBottomMargin
        chevron.contentMode = .Center
        addSubview(chevron)
        self.chevron = chevron
        updateImage()

        addTarget(self, action: Selector("updateImage"), forControlEvents: .TouchDown | .TouchDragEnter | .TouchUpInside | .TouchCancel | .TouchDragExit)
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        if let chevron = chevron {
            chevron.frame = bounds.fromRight().growLeft(frame.height)
        }
    }

    func updateImage() {
        if highlighted {
            chevron?.setSVGImage("abracket_selected")
        }
        else {
            chevron?.setSVGImage("abracket_normal")
        }
    }

}
