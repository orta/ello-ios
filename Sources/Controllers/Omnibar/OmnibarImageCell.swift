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
        static let bottomMargin = CGFloat(15)
        static let editingHeight = CGFloat(80)
    }

    public let flImageView = FLAnimatedImageView()
    public var reordering = false

    public var omnibarImage: UIImage? {
        get { return flImageView.image }
        set { flImageView.image = newValue }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        flImageView.clipsToBounds = true
        flImageView.contentMode = .ScaleAspectFill
        contentView.addSubview(flImageView)
    }

    required public init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        var frame = contentView.bounds
        if reordering {
            frame = frame.inset(topBottom: Size.bottomMargin / 2)
        }
        flImageView.frame = frame
    }

    public class func heightForImage(image: UIImage, tableWidth: CGFloat, editing: Bool) -> CGFloat {
        if editing {
            return Size.editingHeight
        }

        var cellWidth = tableWidth
        let imageWidth = max(image.size.width, 1)
        var height = image.size.height * cellWidth / imageWidth
        if editing {
            height += Size.bottomMargin
        }
        return height
    }

}
