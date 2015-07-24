//
//  FakeStreamTextCellSizeCalculator.swift
//  Ello
//
//  Created by Sean on 3/4/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Ello


public class FakeStreamTextCellSizeCalculator: StreamTextCellSizeCalculator {

    override public func processCells(cellItems:[StreamCellItem], withWidth: CGFloat, completion:StreamTextCellSizeCalculated) {
        self.completion = completion
        self.cellItems = cellItems
        for item in cellItems {
            item.oneColumnCellHeight = AppSetup.Size.calculatorHeight
            item.multiColumnCellHeight = AppSetup.Size.calculatorHeight
        }
        completion()
    }
}
