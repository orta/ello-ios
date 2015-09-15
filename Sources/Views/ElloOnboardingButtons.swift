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

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.sharedSetup()
    }

    func sharedSetup() {
        self.setSVGImages("abracket", degree: 180.0)
        self.backgroundColor = enabled ? .greyE5() : .greyF1()
    }

}

public class OnboardingSkipButton: WhiteElloButton {

    override public func sharedSetup() {
        super.sharedSetup()
        self.setTitle(NSLocalizedString("Skip", comment: "Skip button"), forState: .Normal)
    }

}

public class OnboardingNextButton: LightElloButton {
    var chevron: UIImageView?

    override public func updateStyle() {
        super.updateStyle()
        updateImage()
    }

    override public func sharedSetup() {
        super.sharedSetup()
        titleEdgeInsets.right = 20

        let chevron = UIImageView()
        chevron.autoresizingMask = [.FlexibleLeftMargin, .FlexibleTopMargin, .FlexibleBottomMargin]
        chevron.contentMode = .Center
        addSubview(chevron)
        self.chevron = chevron

        addTarget(self, action: Selector("updateImage"), forControlEvents: [.TouchDown, .TouchDragEnter, .TouchUpInside, .TouchCancel, .TouchDragExit])
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        if let chevron = chevron {
            chevron.frame = bounds.fromRight().growLeft(frame.height)
        }
    }

    func updateImage() {
        if !enabled {
            chevron?.setSVGImage("abracket_disabled")
        }
        else if highlighted {
            chevron?.setSVGImage("abracket_selected")
        }
        else {
            chevron?.setSVGImage("abracket_normal")
        }
    }

}

public class FollowAllElloButton: ElloButton {

    required public init(frame: CGRect) {
        super.init(frame: frame)
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override public func updateStyle() {
        self.backgroundColor = selected ? .blackColor() : .whiteColor()
        updateOutline()
    }

    override public func sharedSetup() {
        self.titleLabel?.font = UIFont.typewriterFont(14.0)
        self.titleLabel?.numberOfLines = 1
        self.setTitleColor(UIColor.blackColor(), forState: .Normal)
        self.setTitleColor(UIColor.whiteColor(), forState: .Selected)
        self.setTitleColor(UIColor.greyA(), forState: .Disabled)
        self.backgroundColor = selected ? .blackColor() : .whiteColor()
    }

    private func updateOutline() {
        self.layer.borderColor = (currentTitleColor ?? UIColor.whiteColor()).CGColor
        self.layer.borderWidth = 1
    }

}
