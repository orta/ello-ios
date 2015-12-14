//
//  StreamToggleCell.swift
//  Ello
//
//  Created by Sean on 3/29/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public class StreamToggleCell: UICollectionViewCell {

    let closedMessage = NSLocalizedString("Tap to View.", comment: "Tap to View.")
    let openedMessage = NSLocalizedString("Tap to Hide.", comment: "Tap to Hide.")

    weak var label:ElloToggleLabel!
}
