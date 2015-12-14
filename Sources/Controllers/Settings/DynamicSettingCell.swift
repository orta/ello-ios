//
//  DynamicSettingCell.swift
//  Ello
//
//  Created by Tony DiPasquale on 4/13/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public protocol DynamicSettingCellDelegate {
    func toggleSetting(setting: DynamicSetting, value: Bool)
    func deleteAccount()
}

public class DynamicSettingCell: UITableViewCell {
    @IBOutlet public weak var titleLabel: UILabel!
    public weak var descriptionLabel: ElloToggleLabel!
    @IBOutlet public weak var toggleButton: ElloToggleButton!
    @IBOutlet public weak var deleteButton: ElloToggleButton!

    public var delegate: DynamicSettingCellDelegate?
    public var setting: DynamicSetting?

    public override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.font = .defaultFont()
        titleLabel.textColor = .blackColor()
        descriptionLabel.font = .defaultFont()
        descriptionLabel.textColor = .greyA()
    }

    @IBAction public func toggleButtonTapped() {
        if let setting = setting {
            delegate?.toggleSetting(setting, value: !toggleButton.value)
            toggleButton.value = !toggleButton.value
        }
    }

    @IBAction public func deleteButtonTapped() {
        delegate?.deleteAccount()
    }
}
