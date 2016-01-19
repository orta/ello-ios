//
//  ElloPostToolBarOption.swift
//  Ello
//
//  Created by Sean on 2/18/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

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
            return imageLabelControl(.Eye)
        case .Comments:
            return ImageLabelControl(icon: CommentsIcon(), title: "")
        case .Loves:
            return imageLabelControl(.Heart)
        case .Repost:
            return imageLabelControl(.Repost)
        case .Share:
            return imageLabelControl(.Share)
        case .Delete:
            return imageLabelControl(.XBox)
        case .Edit:
            return imageLabelControl(.Pencil)
        case .Reply:
            return imageLabelControl(.Reply)
        case .Flag:
            return imageLabelControl(.Flag)
        }
    }

    func barButtonItem() -> UIBarButtonItem {
        return UIBarButtonItem(customView: self.imageLabelControl())
    }

    private func imageLabelControl(interfaceImage: Interface.Image, count: Int = 0) -> UIControl {
        let icon = UIImageView(image: interfaceImage.normalImage)
        let iconSelected = UIImageView(image: interfaceImage.selectedImage)
        var iconDisabled: UIView? = nil
        if let disabledImage = interfaceImage.disabledImage {
            iconDisabled = UIImageView(image: disabledImage)
        }
        let basicIcon = BasicIcon(normalIconView: icon, selectedIconView: iconSelected, disabledIconView: iconDisabled)
        return ImageLabelControl(icon: basicIcon, title: count.numberToHuman())
    }

}
