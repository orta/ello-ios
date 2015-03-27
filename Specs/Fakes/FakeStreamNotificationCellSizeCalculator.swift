//
//  FakeStreamNotificationCellSizeCalculator.swift
//  Ello
//
//  Created by Sean on 3/3/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation


class FakeStreamNotificationCellSizeCalculator: StreamNotificationCellSizeCalculator {

    override func processCells(cellItems:[StreamCellItem], withWidth: CGFloat, completion:StreamTextCellSizeCalculated) {
        self.completion = completion
        self.cellItems = cellItems
        completion()
    }

}
