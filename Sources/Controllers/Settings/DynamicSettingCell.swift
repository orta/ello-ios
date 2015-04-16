//
//  DynamicSettingCell.swift
//  Ello
//
//  Created by Tony DiPasquale on 4/13/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit

public protocol DynamicSettingCellDelegate {
    func toggleSetting(setting: DynamicSetting, value: Bool)
}

public class DynamicSettingCell: UITableViewCell {
    @IBOutlet public weak var titleLabel: UILabel!
    @IBOutlet public weak var descriptionLabel: ElloToggleLabel!
    @IBOutlet public weak var toggleButton: ElloToggleButton!

    public var delegate: DynamicSettingCellDelegate?
    public var setting: DynamicSetting?

    @IBAction public func toggleButtonTapped() {
        if let setting = setting {
            delegate?.toggleSetting(setting, value: !toggleButton.value)
            toggleButton.value = !toggleButton.value
        }
    }
}
