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
                    let setting = DynamicSetting(label: "Test", key: "has_sharing_enabled", dependentOn: [], conflictsWith: [], info: "description", linkLabel: .None, linkURL: .None)
                    let profile: Profile = stub(["hasSharingEnabled": false])
                    let user: User = stub([
                        "hasSharingEnabled": false,
                        "profile": profile
                        ])
                    let cell = DynamicSettingCell.loadFromNib() as DynamicSettingCell
                    DynamicSettingCellPresenter.configure(cell, setting: setting, currentUser: user)

                    expect(cell.titleLabel.text) == setting.label
                    expect(cell.descriptionLabel.text) == setting.info
                    expect(cell.toggleButton.value) == false
                    expect(cell.toggleButton.hidden) == false
                    expect(cell.toggleButton.enabled) == true
                    expect(cell.deleteButton.hidden) == true
                }

                it("configures the cell from the setting and uses the profile setting") {
                    let setting = DynamicSetting(label: "Test", key: "has_sharing_enabled", dependentOn: [], conflictsWith: [], info: "description", linkLabel: .None, linkURL: .None)
                    let profile: Profile = stub(["hasSharingEnabled": true])
                    let user: User = stub([
                        "hasSharingEnabled": false,
                        "profile": profile
                        ])
                    let cell = DynamicSettingCell.loadFromNib() as DynamicSettingCell
                    DynamicSettingCellPresenter.configure(cell, setting: setting, currentUser: user)

                    expect(cell.titleLabel.text) == setting.label
                    expect(cell.descriptionLabel.text) == setting.info
                    expect(cell.toggleButton.value) == true
                    expect(cell.toggleButton.hidden) == false
                    expect(cell.toggleButton.enabled) == true
                    expect(cell.deleteButton.hidden) == true
                }

                it("configures the cell from the setting and disables if dependent is false") {
                    let setting = DynamicSetting(label: "Test", key: "has_sharing_enabled", dependentOn: ["is_public"], conflictsWith: [], info: "description", linkLabel: .None, linkURL: .None)
                    let profile: Profile = stub(["hasSharingEnabled": true, "isPublic": false])
                    let user: User = stub([
                        "hasSharingEnabled": false,
                        "profile": profile
                        ])
                    let cell = DynamicSettingCell.loadFromNib() as DynamicSettingCell
                    DynamicSettingCellPresenter.configure(cell, setting: setting, currentUser: user)
                    let isVisible = DynamicSettingCellPresenter.isVisible(setting: setting, currentUser: user)

                    expect(cell.titleLabel.text) == setting.label
                    expect(cell.descriptionLabel.text) == setting.info
                    expect(cell.toggleButton.value) == true
                    expect(cell.toggleButton.hidden) == false
                    expect(cell.toggleButton.enabled) == false
                    expect(isVisible) == false
                    expect(cell.deleteButton.hidden) == true
                }

                it("configures the cell from the setting and enables if dependent is true") {
                    let setting = DynamicSetting(label: "Test", key: "has_sharing_enabled", dependentOn: ["is_public"], conflictsWith: [], info: "description", linkLabel: .None, linkURL: .None)
                    let profile: Profile = stub(["hasSharingEnabled": false, "isPublic": true])
                    let user: User = stub([
                        "hasSharingEnabled": false,
                        "profile": profile
                        ])
                    let cell = DynamicSettingCell.loadFromNib() as DynamicSettingCell
                    DynamicSettingCellPresenter.configure(cell, setting: setting, currentUser: user)
                    let isVisible = DynamicSettingCellPresenter.isVisible(setting: setting, currentUser: user)

                    expect(cell.titleLabel.text) == setting.label
                    expect(cell.descriptionLabel.text) == setting.info
                    expect(cell.toggleButton.value) == false
                    expect(cell.toggleButton.hidden) == false
                    expect(cell.toggleButton.enabled) == true
                    expect(isVisible) == true
                    expect(cell.deleteButton.hidden) == true
                }

                it("configures the cell from the setting and disables if conflicted is true") {
                    let setting = DynamicSetting(label: "Test", key: "has_sharing_enabled", dependentOn: [], conflictsWith: ["allows_analytics"], info: "description", linkLabel: .None, linkURL: .None)
                    let profile: Profile = stub(["hasSharingEnabled": true, "allowsAnalytics": true])
                    let user: User = stub([
                        "profile": profile
                        ])
                    let cell = DynamicSettingCell.loadFromNib() as DynamicSettingCell
                    DynamicSettingCellPresenter.configure(cell, setting: setting, currentUser: user)

                    expect(cell.titleLabel.text) == setting.label
                    expect(cell.descriptionLabel.text) == setting.info
                    expect(cell.toggleButton.value) == true
                    expect(cell.toggleButton.hidden) == false
                    expect(cell.toggleButton.enabled) == false
                    expect(cell.deleteButton.hidden) == true
                }

                it("configures the cell from the setting and enables if conflicted if false") {
                    let setting = DynamicSetting(label: "Test", key: "has_sharing_enabled", dependentOn: [], conflictsWith: ["allows_analytics"], info: "description", linkLabel: .None, linkURL: .None)
                    let profile: Profile = stub(["hasSharingEnabled": false, "allowsAnalytics": false])
                    let user: User = stub([
                        "profile": profile
                        ])
                    let cell = DynamicSettingCell.loadFromNib() as DynamicSettingCell
                    DynamicSettingCellPresenter.configure(cell, setting: setting, currentUser: user)

                    expect(cell.titleLabel.text) == setting.label
                    expect(cell.descriptionLabel.text) == setting.info
                    expect(cell.toggleButton.value) == false
                    expect(cell.toggleButton.hidden) == false
                    expect(cell.toggleButton.enabled) == true
                    expect(cell.deleteButton.hidden) == true
                }

                it("configures the cell from the setting and disables if conflicted") {
                    let setting = DynamicSetting(label: "Test", key: "has_sharing_enabled", dependentOn: [], conflictsWith: ["allows_analytics"], info: "description", linkLabel: .None, linkURL: .None)
                    let profile: Profile = stub(["s": true, "allowsAnalytics": false])
                    let user: User = stub([
                        "profile": profile
                        ])
                    let cell = DynamicSettingCell.loadFromNib() as DynamicSettingCell
                    DynamicSettingCellPresenter.configure(cell, setting: setting, currentUser: user)

                    expect(cell.titleLabel.text) == setting.label
                    expect(cell.descriptionLabel.text) == setting.info
                    expect(cell.toggleButton.value) == true
                    expect(cell.toggleButton.hidden) == false
                    expect(cell.toggleButton.enabled) == true
                    expect(cell.deleteButton.hidden) == true
                }

                it("configures the cell from the setting and enables if not conflicted") {
                    let setting = DynamicSetting(label: "Test", key: "has_sharing_enabled", dependentOn: [], conflictsWith: ["allows_analytics"], info: "description", linkLabel: .None, linkURL: .None)
                    let profile: Profile = stub(["hasSharingEnabled": false, "allowsAnalytics": true])
                    let user: User = stub([
                        "profile": profile
                        ])
                    let cell = DynamicSettingCell.loadFromNib() as DynamicSettingCell
                    DynamicSettingCellPresenter.configure(cell, setting: setting, currentUser: user)

                    expect(cell.titleLabel.text) == setting.label
                    expect(cell.descriptionLabel.text) == setting.info
                    expect(cell.toggleButton.value) == false
                    expect(cell.toggleButton.hidden) == false
                    expect(cell.toggleButton.enabled) == false
                    expect(cell.deleteButton.hidden) == true
                }
            }

            context("delete account setting") {
                it("configures the cell from the setting") {
                    let setting = DynamicSetting.accountDeletionSetting
                    let profile: Profile = stub([:])
                    let user: User = stub([
                        "profile": profile
                        ])
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
