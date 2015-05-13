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
    public static func svgItem(imageName: String, insets: UIEdgeInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)) -> UITabBarItem {
        let iconImage = SVGKImage(named: "\(imageName)_normal.svg").UIImage!
        let iconSelectedImage = SVGKImage(named: "\(imageName)_selected.svg").UIImage!
        let item = UITabBarItem(title: nil, image: iconImage, selectedImage: iconSelectedImage)
        item.imageInsets = insets
        return item
    }
}
