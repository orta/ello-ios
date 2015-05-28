//
//  FriendsPageController.swift
//  Ello
//
//  Created by Brandon Brisbon on 5/26/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

class FriendsPageController: IntroPageController {

    @IBOutlet weak var friendsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.friendsLabel.font = UIFont.regularBoldFont(16)
    }
}