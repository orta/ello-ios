//
//  InspiredPageController.swift
//  Ello
//
//  Created by Brandon Brisbon on 5/26/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

class InspiredPageController: IntroPageController {

    weak var inspiredLabel: ElloLabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        inspiredLabel.font = .defaultBoldFont(18)
    }
}
