//
//  WelcomePageController.swift
//  Ello
//
//  Created by Brandon Brisbon on 5/26/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

class WelcomePageController: IntroPageController {
    
    @IBOutlet weak var welcomeLabel: ElloLabel!
    @IBOutlet weak var elloLogoImage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.welcomeLabel.font = UIFont.regularBoldFont(16)
    }
}