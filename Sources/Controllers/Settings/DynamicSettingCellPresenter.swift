//
//  DynamicSettingCellPresenter.swift
//  Ello
//
//  Created by Tony DiPasquale on 4/14/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit

public struct DynamicSettingCellPresenter {
    public static func configure(cell: DynamicSettingCell, setting: DynamicSetting, currentUser: User) {
        cell.titleLabel.text = setting.label
        cell.descriptionLabel.setLabelText(setting.info ?? "")
        cell.toggleButton.value = currentUser.profile?.propertyForSettingsKey(setting.key) ?? false
    }
}
