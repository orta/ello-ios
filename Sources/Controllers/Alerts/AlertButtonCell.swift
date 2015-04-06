//
//  AlertButtonCell.swift
//  Ello
//
//  Created by Gordon Fontenot on 4/2/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

class AlertButtonCell: UITableViewCell {
    
}

extension AlertButtonCell {
    class func nib() -> UINib {
        return UINib(nibName: "AlertButtonCell", bundle: .None)
    }

    class func reuseIdentifier() -> String {
        return "AlertButtonCell"
    }
}