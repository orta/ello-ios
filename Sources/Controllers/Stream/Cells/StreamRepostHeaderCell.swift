//
//  StreamRepostHeaderCell.swift
//  Ello
//
//  Created by Ryan Boyajian on 4/23/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

public class StreamRepostHeaderCell: UICollectionViewCell, ElloTextViewDelegate {

    @IBOutlet weak var viaTextViewHeight: NSLayoutConstraint!
    @IBOutlet weak var viaTextView: ElloTextView!
    @IBOutlet weak var sourceTextView: ElloTextView!
    weak var userDelegate: UserDelegate?

    override public func awakeFromNib() {
        super.awakeFromNib()
        viaTextView.textViewDelegate = self
        sourceTextView.textViewDelegate = self
    }

    func textViewTapped(link: String, object: ElloAttributedObject) {
        switch object {
        case let .AttributedUserId(userId):
            userDelegate?.userTappedParam(userId)
        default: break
        }
    }

}
