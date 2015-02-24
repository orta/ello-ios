//
//  ElloNavigationBar.swift
//  Ello
//
//  Created by Colin Gray on 2/24/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

class ElloNavigationBar : UINavigationBar {
    struct Size {
        static let height : CGFloat = 30
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.opaque = true
        self.translucent = false
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.opaque = true
        self.translucent = false
    }

    override func intrinsicContentSize() -> CGSize {
        var size = super.intrinsicContentSize()
        size.height = Size.height
        return size
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if let topItem = self.topItem {
            if let view = topItem.titleView {
                view.frame = view.frame.atY(0).withHeight(self.frame.height)
                println("titleView: \(view.frame)")
            }
        }
    }
}