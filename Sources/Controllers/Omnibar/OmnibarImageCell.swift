//
//  OmnibarImageCell.swift
//  Ello
//
//  Created by Colin Gray on 8/18/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public class OmnibarImageCell: UITableViewCell {
    class func reuseIdentifier() -> String { return "OmnibarImageCell" }

    struct Size {
        static let margins = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        static let bottomMargin = CGFloat(15)
    }

    public let flImageView = FLAnimatedImageView()

    public var omnibarImage: UIImage? {
        get { return flImageView.image }
        set { flImageView.image = newValue }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(flImageView)
    }

    required public init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        flImageView.frame = contentView.bounds.inset(Size.margins)
    }

    public class func heightForImage(image: UIImage, tableWidth: CGFloat) -> CGFloat {
        return image.size.height * tableWidth / image.size.width + Size.margins.top + Size.margins.bottom
    }

}
