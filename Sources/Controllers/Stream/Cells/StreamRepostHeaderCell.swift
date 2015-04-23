//
//  StreamRepostHeaderCell.swift
//  Ello
//
//  Created by Ryan Boyajian on 4/23/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

public class StreamRepostHeaderCell: UICollectionViewCell, UIWebViewDelegate {

    @IBOutlet weak var viaTextViewHeight: NSLayoutConstraint!
    @IBOutlet weak var viaTextView: ElloTextView!
    @IBOutlet weak var sourceTextView: ElloTextView!

}