//
//  DrawerCell.swift
//  Ello
//
//  Created by Sean on 6/1/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public class DrawerCell: UITableViewCell {
    @IBOutlet weak public var label: UILabel!
    @IBOutlet weak public var line: UIView!
}

public extension DrawerCell {
    class func nib() -> UINib {
        return UINib(nibName: "DrawerCell", bundle: .None)
    }

    class func reuseIdentifier() -> String {
        return "DrawerCell"
    }
}
