//
//  AlertCell.swift
//  Ello
//
//  Created by Gordon Fontenot on 4/2/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

class AlertCell: UITableViewCell {
    weak var label: ElloLabel!
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
}

extension AlertCell {
    class func nib() -> UINib {
        return UINib(nibName: "AlertCell", bundle: .None)
    }

    class func reuseIdentifier() -> String {
        return "AlertCell"
    }
}
