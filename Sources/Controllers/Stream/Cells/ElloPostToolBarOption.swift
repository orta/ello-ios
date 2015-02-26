//
//  ElloPostToolBarOption.swift
//  Ello
//
//  Created by Sean on 2/18/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit

enum ElloPostToolBarOption {
    case Views
    case Comments
    case Loves
    case Repost
    case Share
    case Delete
    case Edit
    case Reply
    case Flag

    func button() -> UIButton {
        switch self {
        case .Views:
            return normalButton("eye-icon")
        case .Comments:
            return commentButon()
        case .Loves:
            return normalButton("heart-icon")
        case .Repost:
            return normalButton("repost-icon")
        case .Share:
            return normalButton("share-icon")
        case .Delete:
            return normalButton("eye-icon")
        case .Edit:
            return normalButton("eye-icon")
        case .Reply:
            return normalButton("reply-icon")
        case .Flag:
            return normalButton("flag-icon")
        }
    }

    func barButtonItem() -> UIBarButtonItem {
        return UIBarButtonItem(customView: self.button())
    }

    private func normalButton(imageName: String, count: Int? = nil) -> UIButton {
        let image = UIImage(named: imageName)
        let button = StreamFooterButton()
        var title = ""
        if let count = count {
            title = String(count)
        }
        button.setImage(image, forState: .Normal)
        button.setButtonTitleWithPadding(title)
        return button
    }

    private func commentButon(count: Int? = nil) -> UIButton {
        let button = CommentButton()

        var title = ""
        if let count = count {
            title = String(count)
        }
        button.setButtonTitleWithPadding(title, titlePadding: 13.0, contentPadding: 15.0)
        return button
    }
}