//
//  ElloEquallySpacedLayout.swift
//  Ello
//
//  Created by Colin Gray on 2/26/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

class ElloEquallySpacedLayout : UIView {

    override func layoutSubviews() {
        super.layoutSubviews()

        let views = self.subviews as [UIView]
        if views.count > 0 {
            var x : CGFloat = 0
            var w : CGFloat = self.frame.size.width / CGFloat(views.count)
            for view in views {
                let frame = CGRect(x: x, y: 0, width: w, height: self.frame.size.height)
                view.frame = frame
                x += w
            }
        }
    }

}