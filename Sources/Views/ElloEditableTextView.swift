//
//  ElloEditableTextView.swift
//  Ello
//
//  Created by Tony DiPasquale on 4/2/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit

class ElloEditableTextView: UITextView {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.delegate = self
    }
}

extension ElloEditableTextView: UITextViewDelegate {
    func textViewDidBeginEditing(textView: UITextView) {
        UIView.animateWithDuration(0.2) {
            self.backgroundColor = UIColor.whiteColor()
        }
    }

    func textViewDidEndEditing(textView: UITextView) {
        UIView.animateWithDuration(0.2) {
            self.backgroundColor = UIColor.greyE5()
        }
    }
}
