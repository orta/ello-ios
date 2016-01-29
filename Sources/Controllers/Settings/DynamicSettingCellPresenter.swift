//
//  DynamicSettingCellPresenter.swift
//  Ello
//
//  Created by Tony DiPasquale on 4/14/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public struct DynamicSettingCellPresenter {
    public static func isVisible(setting setting: DynamicSetting, currentUser: User) -> Bool {
        if setting.key == DynamicSetting.accountDeletionSetting.key {
            return true
        }
        else {
            for dependentKey in setting.dependentOn {
                if currentUser.propertyForSettingsKey(dependentKey) == false {
                    return false
                }
            }
            for conflictKey in setting.conflictsWith {
                if currentUser.propertyForSettingsKey(conflictKey) == true {
                    return false
                }
            }

            return true
        }
    }

    public static func configure(cell: DynamicSettingCell, setting: DynamicSetting, currentUser: User) {
        cell.titleLabel.text = setting.label
        cell.descriptionLabel.setLabelText(setting.info ?? "")

        if setting.key == DynamicSetting.accountDeletionSetting.key {
            cell.toggleButton.hidden = true
            cell.deleteButton.hidden = false
            cell.deleteButton.text = NSLocalizedString("Delete", comment: "delete button")
            cell.contentView.hidden = false
        } else {
            cell.toggleButton.hidden = false
            cell.deleteButton.hidden = true
            cell.toggleButton.value = currentUser.propertyForSettingsKey(setting.key) ?? false

            let visible = isVisible(setting: setting, currentUser: currentUser)
            cell.contentView.hidden = !visible
        }
    }
}
