//
//  ElloEquallySpacedLayout.swift
//  Ello
//
//  Created by Colin Gray on 2/26/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

class ElloEquallySpacedLayout : UIView {
    var margins : UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0){
        didSet {
            setNeedsLayout()
        }
    }
    var spacing : CGFloat = CGFloat(0) {
        didSet {
            if spacing < CGFloat(0) {
                spacing = CGFloat(0)
            }
            else {
                setNeedsLayout()
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let views = self.subviews as [UIView]
        if views.count > 0 {
            var x = margins.left
            var y = margins.top
            var w = (self.frame.size.width - margins.left - margins.right - CGFloat(views.count - 1) * spacing) / CGFloat(views.count)
            var h = self.frame.size.height - margins.top - margins.bottom
            for view in views {
                let frame = CGRect(x: x, y: y, width: w, height: h)
                view.frame = frame
                x += w
                x += spacing
            }
        }
    }

}
