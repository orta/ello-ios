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
            return normalButton("eye-icon")
        case .Delete:
            return normalButton("eye-icon")
        case .Edit:
            return normalButton("eye-icon")
        }
    }

    func barButtonItem() -> UIBarButtonItem {
        return UIBarButtonItem(customView: self.button())
    }

    private func normalButton(imageName: String, count: Int? = nil) -> UIButton {
        let image = UIImage(named: imageName)
        let button = StreamFooterButton()
        button.sizeToFit()
        if let count = count {
            button.setButtonTitle(String(count))
        }
        button.setImage(image, forState: .Normal)
        button.contentMode = .Center
        return button
    }

    private func commentButon(count: Int? = nil) -> UIButton {
        let button = CommentButton()
        button.sizeToFit()
        if let count = count {
            button.setButtonTitle(String(count))
        }
        button.contentMode = .Center
        return button
    }
}