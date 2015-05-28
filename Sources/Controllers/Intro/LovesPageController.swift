//
//  LovesPageController.swift
//  Ello
//
//  Created by Brandon Brisbon on 5/26/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

class LovesPageController: IntroPageController {

    @IBOutlet weak var lovesLabel: ElloLabel!
    @IBOutlet weak var getStartedButton: LightElloButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lovesLabel.font = UIFont.regularBoldFont(16)
        self.getStartedButton.titleLabel!.font = UIFont.typewriterFont(12)
        self.getStartedButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        self.getStartedButton.setBackgroundImage(UIImage.imageWithColor(UIColor.whiteColor()), forState: UIControlState.Normal)
    }
    
    @IBAction func didTouchGetStarted(sender: AnyObject) {
        self.parentViewController?.dismissViewControllerAnimated(false, completion: { () -> Void in })
    }
}