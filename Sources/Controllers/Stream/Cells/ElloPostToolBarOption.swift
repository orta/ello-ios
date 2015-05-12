//
//  ElloPostToolBarOption.swift
//  Ello
//
//  Created by Sean on 2/18/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit
import SVGKit

public enum ElloPostToolBarOption {
    case Views
    case Comments
    case Loves
    case Repost
    case Share
    case Delete
    case Edit
    case Reply
    case Flag

    func imageLabelControl() -> UIControl {
        switch self {
        case .Views:
            return imageLabelControl("eye")
        case .Comments:
            return imageLabelControl("bubble")
        case .Loves:
            return imageLabelControl("heartplus")
        case .Repost:
            return imageLabelControl("repost")
        case .Share:
            return imageLabelControl("share")
        case .Delete:
            return imageLabelControl("xbox")
        case .Edit:
            return imageLabelControl("pencil")
        case .Reply:
            return imageLabelControl("reply")
        case .Flag:
            return imageLabelControl("flag")
        }
    }

    func barButtonItem() -> UIBarButtonItem {
        return UIBarButtonItem(customView: self.imageLabelControl())
    }

    private func imageLabelControl(imageName: String, count: Int? = nil) -> UIControl {
        let iconImage = SVGKImage(named: "\(imageName)_normal.svg").UIImage!
        let iconSelectedImage = SVGKImage(named: "\(imageName)_selected.svg").UIImage!
        let icon = UIImageView(image: iconImage)
        let iconSelected = UIImageView(image: iconSelectedImage)
        let basicIcon = BasicIcon(normalIconView: icon, selectedIconView: iconSelected)
        return ImageLabelControl(icon: basicIcon, title: title(count: count))
    }

    private func title(count: Int? = nil) -> String {
        var title = ""
        if let count = count {
            title = String(count)
        }
        return title
    }
}
