//
//  StreamFooterCell.swift
//  Ello
//
//  Created by Sean Dougherty on 12/10/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit
import Foundation

class StreamFooterCell: UICollectionViewCell {

    @IBOutlet weak var eyeButton: StreamFooterButton!
    @IBOutlet weak var dotButton: StreamFooterButton!
    @IBOutlet weak var heartButton: StreamFooterButton!
    @IBOutlet weak var repostButton: StreamFooterButton!
    @IBOutlet weak var chevronButton: StreamFooterButton!

    var views:String? {
        get { return eyeButton.titleForState(.Normal) }
        set { eyeButton.setButtonTitle(newValue) }
    }

    var comments:String? {
        get { return dotButton.titleForState(.Normal) }
        set { dotButton.setButtonTitle(newValue) }
    }

    var loves:String? {
        get { return heartButton.titleForState(.Normal) }
        set { heartButton.setButtonTitle(newValue) }
    }

    var reposts:String? {
        get { return repostButton.titleForState(.Normal) }
        set { repostButton.setButtonTitle(newValue) }
    }
}
