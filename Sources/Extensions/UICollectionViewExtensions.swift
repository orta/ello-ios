//
//  UICollectionViewExtensions.swift
//  Ello
//
//  Created by Ryan Boyajian on 4/2/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

extension UICollectionView {
    public func lastIndexPathForSection(section: Int) -> NSIndexPath? {
        if self.numberOfItemsInSection(section) > 0 {
            return NSIndexPath(forItem: self.numberOfItemsInSection(section) - 1, inSection: section)
        }
        return nil
    }
}
