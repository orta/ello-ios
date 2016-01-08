//
//  DiscoverStreamPickerCell.swift
//  Ello
//
//  Created by Colin Gray on 1/7/2016.
//  Copyright (c) 2016 Ello. All rights reserved.
//

class DiscoverStreamPickerCell: UICollectionViewCell {
    static let reuseIdentifier = "DiscoverStreamPickerCell"
    
    weak var discoverStreamPickerDelegate : DiscoverStreamPickerDelegate!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    var discoverType: DiscoverType {
        get {
            return discoverTypes.safeValue(segmentedControl.selectedSegmentIndex) ?? .Recommended
        }
        set {
            if let index = discoverTypes.indexOf(newValue) {
                segmentedControl.selectedSegmentIndex = index
            }
        }
    }

    private var discoverTypes: [DiscoverType] = [
        .Recommended,
        .Trending,
        .Recent,
    ]


    @IBAction func pickerValueChanged() {
        discoverStreamPickerDelegate?.discoverPickerTapped(discoverType)
    }

}
