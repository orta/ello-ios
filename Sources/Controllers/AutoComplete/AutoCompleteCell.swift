//
//  AutoCompleteCell.swift
//  Ello
//
//  Created by Sean on 6/29/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public class AutoCompleteCell: UITableViewCell {
    @IBOutlet weak public var name: UILabel!
    @IBOutlet weak public var avatar: AvatarButton!
    @IBOutlet weak public var line: UIView!
}

public extension AutoCompleteCell {
    class func nib() -> UINib {
        return UINib(nibName: "AutoCompleteCell", bundle: .None)
    }

    class func reuseIdentifier() -> String {
        return "AutoCompleteCell"
    }

    class func cellHeight() -> CGFloat {
        return 49
    }
}

