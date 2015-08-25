//
//  OmnibarImageDownloadCell.swift
//  Ello
//
//  Created by Colin Gray on 8/24/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public class OmnibarImageDownloadCell: UITableViewCell {
    class func reuseIdentifier() -> String { return "OmnibarImageDownloadCell" }

    struct Size {
        static let height = CGFloat(100)
    }

    public let logoView = PulsingCircle()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(logoView)
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        logoView.frame = contentView.bounds
    }

    override public func didMoveToSuperview() {
        logoView.pulse()
    }

}
