//
//  UITabBarItem.swift
//  Ello
//
//  Created by Sean on 5/11/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit
import SVGKit

extension UITabBarItem {
    public static func svgItem(imageName: String) -> UITabBarItem {
        let iconImage = SVGKImage(named: "\(imageName)_normal.svg").UIImage!
        let iconSelectedImage = SVGKImage(named: "\(imageName)_selected.svg").UIImage!
        let item = UITabBarItem(title: nil, image: iconImage, selectedImage: iconSelectedImage)
        item.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0)
        return item
    }
}
