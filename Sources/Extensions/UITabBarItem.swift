//
//  UITabBarItem.swift
//  Ello
//
//  Created by Sean on 5/11/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

extension UITabBarItem {
    public static func item(interfaceImage: Interface.Image, insets: UIEdgeInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)) -> UITabBarItem {
        let iconImage = interfaceImage.normalImage
        let iconSelectedImage = interfaceImage.selectedImage
        let item = UITabBarItem(title: nil, image: iconImage, selectedImage: iconSelectedImage)
        item.imageInsets = insets
        return item
    }
}
