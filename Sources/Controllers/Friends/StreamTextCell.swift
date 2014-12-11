//
//  StreamTextCell.swift
//  Ello
//
//  Created by Sean Dougherty on 11/22/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import WebKit
import Foundation

class StreamTextCell: UICollectionViewCell {

    @IBOutlet weak var webView: UIWebView!

    var calculatedHeight:CGFloat = 120.0

//    override func preferredLayoutAttributesFittingAttributes(layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes! {
//        let attributes = super.preferredLayoutAttributesFittingAttributes(layoutAttributes)
//        let newSize = CGSize(width: UIScreen.screenWidth(), height: layoutAttributes.size.height)
//        var newFrame = attributes.frame
//        newFrame.size.height = newSize.height
//        newFrame.size.width = newSize.width
//        attributes.frame = newFrame
//        return attributes
//    }

}
