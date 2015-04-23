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
            context("toggle setting") {
                it("configures the cell from the setting") {
                    let setting = DynamicSetting(label: "Test", key: "has_sharing_enabled", info: "description", linkLabel: .None, linkURL: .None)
                    let user = User.fromJSON(stubbedJSONData("profile_updating_user_profile_and_settings", "users")) as! User
                    let cell = DynamicSettingCell.loadFromNib() as DynamicSettingCell
                    DynamicSettingCellPresenter.configure(cell, setting: setting, currentUser: user)
                    
                    expect(cell.titleLabel.text) == setting.label
                    expect(cell.descriptionLabel.text) == setting.info
                    expect(cell.toggleButton.value) == true
                    expect(cell.toggleButton.hidden) == false
                    expect(cell.deleteButton.hidden) == true
                }
            }

            context("delete account setting") {
                it("configures the cell from the setting") {
                    let setting = DynamicSetting.accountDeletionSetting
                    let user = User.fromJSON(stubbedJSONData("profile_updating_user_profile_and_settings", "users")) as! User
                    let cell = DynamicSettingCell.loadFromNib() as DynamicSettingCell
                    DynamicSettingCellPresenter.configure(cell, setting: setting, currentUser: user)
                    
                    expect(cell.titleLabel.text) == setting.label
                    expect(cell.descriptionLabel.text) == setting.info
                    expect(cell.toggleButton.hidden) == true
                    expect(cell.deleteButton.hidden) == false
                }
            }
        }
    }
}
