//
//  DynamicSettingCellPresenter.swift
//  Ello
//
//  Created by Tony DiPasquale on 4/14/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public struct DynamicSettingCellPresenter {
    public static func configure(cell: DynamicSettingCell, setting: DynamicSetting, currentUser: User) {
        cell.titleLabel.text = setting.label
        cell.descriptionLabel.setLabelText(setting.info ?? "")

        if setting.key == DynamicSetting.accountDeletionSetting.key {
            cell.toggleButton.hidden = true
            cell.deleteButton.hidden = false
            cell.deleteButton.setText(NSLocalizedString("Delete", comment: "delete button"))
        } else {
            cell.toggleButton.hidden = false
            cell.deleteButton.hidden = true
            cell.toggleButton.value = currentUser.propertyForSettingsKey(setting.key) ?? false
        }
    }
}
