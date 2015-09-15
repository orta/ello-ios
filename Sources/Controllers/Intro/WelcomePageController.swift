//
//  WelcomePageController.swift
//  Ello
//
//  Created by Brandon Brisbon on 5/26/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

class WelcomePageController: IntroPageController {
    
    weak var welcomeLabel: ElloLabel!
    weak var discoverLabel: ElloLabel!
    @IBOutlet weak var elloLogoImage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        welcomeLabel.font = .regularBoldFont(18)
        discoverLabel.font = .regularBoldFont(18)
        discoverLabel.textColor = .greyA()
    }
}
