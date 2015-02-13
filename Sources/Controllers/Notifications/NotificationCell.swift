//
//  NotificationCell.swift
//  Ello
//
//  Created by Colin Gray on 2/12/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit


class NotificationCell : UICollectionViewCell {

    @IBOutlet var collapsableImageMargin : NSLayoutConstraint!
    @IBOutlet var collapsableMessageMargin : NSLayoutConstraint!

    var messageHtml : String? {
        willSet(newValue) {
            if let value = newValue {
                collapsableMessageMargin.constant = 10
            }
            else {
                collapsableMessageMargin.constant = 0
            }
        }
    }
    var image : UIImage? {
        willSet(newValue) {
            if let image = newValue {
                collapsableImageMargin.constant = 10
            }
            else {
                collapsableImageMargin.constant = 0
            }
        }
    }

}