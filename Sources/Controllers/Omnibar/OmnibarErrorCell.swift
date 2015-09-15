//
//  OmnibarErrorCell.swift
//  Ello
//
//  Created by Colin Gray on 8/18/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public class OmnibarErrorCell: UITableViewCell {
    class func reuseIdentifier() -> String { return "OmnibarErrorCell" }
    struct Size {
        static let margin = CGFloat(10)
        static let height = CGFloat(75)
    }

    public let elloLabel: ElloErrorLabel

    public var url: NSURL? {
        get { return nil }
        set {
            if let url = newValue {
                elloLabel.setLabelText("There was a problem loading the image\n\(url)")
            }
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        elloLabel = ElloErrorLabel()
        elloLabel.numberOfLines = 2
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        elloLabel.frame = contentView.bounds.inset(all: Size.margin)
        elloLabel.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]

        contentView.addSubview(elloLabel)
    }

    required public init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
