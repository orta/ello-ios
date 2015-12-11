//
//  StreamSeeMoreCommentsCell.swift
//  Ello
//
//  Created by Ryan Boyajian on 5/12/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation


public class StreamSeeMoreCommentsCell: UICollectionViewCell {
    @IBOutlet weak public var buttonContainer: UIView!
    @IBOutlet weak public var seeMoreButton: UIButton!

    override public func awakeFromNib() {
        super.awakeFromNib()
        style()
    }

    private func style() {
        buttonContainer.backgroundColor = .greyA()
        seeMoreButton.setTitleColor(UIColor.greyA(), forState: UIControlState.Normal)
        seeMoreButton.backgroundColor = .whiteColor()
        seeMoreButton.titleLabel?.font = .defaultFont()
    }

}
