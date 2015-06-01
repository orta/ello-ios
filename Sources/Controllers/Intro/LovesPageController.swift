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
        lovesLabel.font = .regularBoldFont(18)
        getStartedButton.titleLabel!.font = .typewriterFont(12)
        getStartedButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        getStartedButton.setBackgroundImage(UIImage.imageWithColor(.whiteColor()), forState: .Normal)
    }
    
    @IBAction func didTouchGetStarted(sender: AnyObject) {
        parentViewController?.dismissViewControllerAnimated(false, completion: nil)
    }
}
