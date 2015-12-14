//
//  ElloTabBar.swift
//  Ello
//
//  Created by Sean Dougherty on 11/21/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

public class ElloTabBar: UITabBar {
    struct Size {
        static let height = CGFloat(49)
    }

    private var redDotViews = [(Int, UIView)]()

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        privateInit()
    }

    convenience init() {
        self.init(frame: CGRectZero)
        privateInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        privateInit()
    }

    private func privateInit() {
        self.backgroundColor = UIColor.whiteColor()
        self.translucent = false
        self.opaque = true
        self.barTintColor = UIColor.whiteColor()
        self.tintColor = UIColor.blackColor()
        self.clipsToBounds = true
        self.shadowImage = UIImage.imageWithColor(UIColor.whiteColor())
    }

    public func addRedDotAtIndex(index: Int) -> UIView {
        let redDot: UIView
        if let entryIndex = (redDotViews.indexOf { $0.0 == index }) {
            redDot = redDotViews[entryIndex].1
        }
        else {
            redDot = UIView()
            redDot.backgroundColor = UIColor.redColor()
            redDot.hidden = true
            let redDotEntry = (index, redDot)
            redDotViews.append(redDotEntry)
            addSubview(redDot)
        }

        positionRedDot(redDot, atIndex: index)
        return redDot
    }

    private func tabBarFrameAtIndex(index: Int) -> CGRect {
        let tabBarButtons = subviews.filter {
            $0 is UIControl
        }.sort {
            $0.frame.minX < $1.frame.minX
        }
        return tabBarButtons.safeValue(index)?.frame ?? CGRectZero
    }

    private func positionRedDot(redDot: UIView, atIndex index: Int) {
        let radius: CGFloat = 3
        let diameter = radius * 2
        let margins = CGPoint(x: 0, y: 10)
        let tabBarItemFrame = tabBarFrameAtIndex(index)
        let item = items?[index]
        let imageHalfWidth: CGFloat = (item?.selectedImage?.size.width ?? 0) / 2
        let x = tabBarItemFrame.midX + imageHalfWidth + margins.x
        let frame = CGRect(x: x, y: margins.y, width: diameter, height: diameter)

        redDot.layer.cornerRadius = radius
        redDot.frame = frame
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        for (index, redDot) in redDotViews {
            positionRedDot(redDot, atIndex: index)
        }
    }

}
