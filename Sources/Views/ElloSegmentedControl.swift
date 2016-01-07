//
//  ElloSegmentedControl.swift
//  Ello
//
//  Created by Colin Gray on 1/7/2016.
//  Copyright (c) 2016 Ello. All rights reserved.
//

class ElloSegmentedControl: UISegmentedControl {
    enum ElloSegmentedControlStyle {
        case Compact
        case Normal

        var fontSize: CGFloat {
            switch self {
            case .Compact: return 11
            case .Normal: return 14
            }
        }

        var height: CGFloat {
            switch self {
            case .Compact: return 19
            case .Normal: return 30
            }
        }
    }

    var style: ElloSegmentedControlStyle = .Normal { didSet { updateStyle() }}

    override func awakeFromNib() {
        super.awakeFromNib()
        layer.borderWidth = 1
        tintColor = .blackColor()
        updateStyle()
    }

    private func updateStyle() {
        let fontSize = style.fontSize
        let normalTitleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.blackColor(),
            NSFontAttributeName: UIFont.defaultFont(fontSize)
        ]
        let selectedTitleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: UIFont.defaultFont(fontSize)
        ]
        setTitleTextAttributes(normalTitleTextAttributes, forState: .Normal)
        setTitleTextAttributes(selectedTitleTextAttributes, forState: .Selected)
        setBackgroundImage(UIImage.imageWithColor(UIColor.whiteColor()), forState: .Normal, barMetrics: .Default)
        setBackgroundImage(UIImage.imageWithColor(UIColor.blackColor()), forState: .Selected, barMetrics: .Default)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        frame.size.height = style.height
    }

    override func intrinsicContentSize() -> CGSize {
        return CGSize(width: super.intrinsicContentSize().width, height: style.height)
    }

}
