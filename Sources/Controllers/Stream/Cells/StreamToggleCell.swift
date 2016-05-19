//
//  StreamToggleCell.swift
//  Ello
//
//  Created by Sean on 3/29/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public class StreamToggleCell: UICollectionViewCell {
    static let reuseIdentifier = "StreamToggleCell"

    let closedMessage = InterfaceString.NSFW.Show
    let openedMessage = InterfaceString.NSFW.Hide

    weak var label: ElloToggleLabel!
}
