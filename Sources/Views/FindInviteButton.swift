//
//  FindInviteButton.swift
//  Ello
//
//  Created by Sean on 3/19/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public class FindInviteButton: UIButton {

    required override public init(frame: CGRect) {
        super.init(frame: frame)
        self.sharedSetup()
    }

    required public init(coder: NSCoder) {
        super.init(coder: coder)
        self.sharedSetup()
    }

    func sharedSetup() {
        self.layer.borderColor = UIColor.greyA().CGColor
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = 0.0
        self.titleLabel?.font = UIFont.typewriterFont(11.0)
        self.titleLabel?.numberOfLines = 1
        self.titleEdgeInsets = UIEdgeInsetsMake(1.0, 0.0, 0.0, 0.0)
        self.setTitleColor(UIColor.greyA(), forState: UIControlState.Normal)
        self.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted)
        self.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Selected)
        self.setBackgroundImage(UIImage.imageWithColor(UIColor.whiteColor()), forState: UIControlState.Normal)
        self.setBackgroundImage(UIImage.imageWithColor(UIColor.greyA()), forState: UIControlState.Highlighted)
        self.setBackgroundImage(UIImage.imageWithColor(UIColor.greyA()), forState: UIControlState.Selected)
    }
    
}
