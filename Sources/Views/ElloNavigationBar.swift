//
//  ElloNavigationBar.swift
//  Ello
//
//  Created by Colin Gray on 2/24/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public class ElloNavigationBar : UINavigationBar {
    struct Size {
        static let height : CGFloat = 44
        static let titleViewHeight : CGFloat = 20
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        privateInit()
    }

    required public init(coder: NSCoder) {
        super.init(coder: coder)
    }

    override public func awakeFromNib() {
        super.awakeFromNib()
        privateInit()
    }

    private func privateInit() {
        self.opaque = true
        self.translucent = false
        self.tintColor = UIColor.greyA()
    }

    override public func intrinsicContentSize() -> CGSize {
        var size = super.intrinsicContentSize()
        size.height = Size.height
        return size
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        if let topItem = self.topItem {
            if let view = topItem.titleView {
                view.frame = view.frame
                    .withHeight(Size.titleViewHeight)
                    .atY((self.frame.height - Size.titleViewHeight) / 2)
            }
        }
    }
}
