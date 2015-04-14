//
//  DynamicSettingCellPresenterSpec.swift
//  Ello
//
//  Created by Tony DiPasquale on 4/14/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble

class DynamicSettingCellPresenterSpec: QuickSpec {
    override func spec() {
        describe("configure") {
            it("configures the cell from the setting") {
                let setting = DynamicSetting(label: "Test", key: "test_key", info: "description", linkLabel: .None, linkURL: .None)
                let cell = DynamicSettingCell.loadFromNib() as DynamicSettingCell
                DynamicSettingCellPresenter.configure(cell, setting: setting)

                expect(cell.titleLabel.text) == setting.label
                expect(cell.descriptionLabel.text) == setting.info
            }
        }
    }
}
