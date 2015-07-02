//
//  UserAvatarsCellPresenter.swift
//  Ello
//
//  Created by Ryan Boyajian on 6/29/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation
import SVGKit

public struct UserAvatarsCellPresenter {

    public static func configure(
        cell:UICollectionViewCell,
        streamCellItem:StreamCellItem,
        streamKind: StreamKind,
        indexPath: NSIndexPath,
        currentUser: User?)
    {
        if let cell = cell as? UserAvatarsCell, let model = streamCellItem.jsonable as? UserAvatarCellModel
        {
            cell.imageView.image = SVGKImage(named: model.icon).UIImage
            cell.userAvatarCellModel = model
            if model.hasUsers {
                cell.loadingLabel.hidden = true
            }
            else {
                cell.loadingLabel.hidden = false
            }
        }
    }
}
