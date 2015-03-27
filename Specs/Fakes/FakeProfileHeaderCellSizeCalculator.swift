//
//  FakeProfileHeaderCellSizeCalculator.swift
//  Ello
//
//  Created by Ryan Boyajian on 3/24/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

class FakeProfileHeaderCellSizeCalculator: ProfileHeaderCellSizeCalculator {

    override func processCells(cellItems:[StreamCellItem], withWidth: CGFloat, completion:ElloEmptyCompletion) {
        self.completion = completion
        self.cellItems = cellItems
        completion()
    }

}
