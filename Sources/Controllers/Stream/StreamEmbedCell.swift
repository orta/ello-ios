//
//  StreamEmbedCell.swift
//  Ello
//
//  Created by Ryan Boyajian on 4/20/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation
import SVGKit

public class StreamEmbedCell: StreamImageCell {

    @IBOutlet weak var playIcon: UIImageView!
    public var embedUrl: NSURL?

    @IBAction override func imageTapped(sender: UIButton) {
        if let url = embedUrl {
            postNotification(externalWebNotification, url.URLString)
        }
    }

    public func setPlayImageIcon(icon: String) {
        playIcon.image = SVGKImage(named: icon).UIImage!
    }
    
}
