//
//  ElloNavigationBar.swift
//  Ello
//
//  Created by Colin Gray on 2/24/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public class ElloNavigationBar : UINavigationBar {
    struct Size {
        static let height : CGFloat = 64
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        privateInit()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override public func awakeFromNib() {
        super.awakeFromNib()
        privateInit()
    }

    private func privateInit() {
        self.tintColor = UIColor.greyA()
        self.clipsToBounds = true
        self.shadowImage = UIImage.imageWithColor(UIColor.whiteColor())
        self.backgroundColor = UIColor.whiteColor()
        self.translucent = false
        self.opaque = true
        self.barTintColor = UIColor.whiteColor()

        let bar = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: 20))
        bar.autoresizingMask = [.FlexibleWidth, .FlexibleBottomMargin]
        bar.backgroundColor = UIColor.blackColor()
        addSubview(bar)
    }

    override public func intrinsicContentSize() -> CGSize {
        var size = super.intrinsicContentSize()
        size.height = Size.height
        return size
    }
}
