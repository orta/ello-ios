//
//  CommentsIcon.swift
//  Ello
//
//  Created by Colin Gray on 9/22/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public class CommentsIcon: BasicIcon {
    private let commentTailView: UIView

    public init() {
        let iconImage = Interface.Image.BubbleBody.normalImage
        let iconSelectedImage = Interface.Image.BubbleBody.selectedImage
        let icon = UIImageView(image: iconImage)
        let iconSelected = UIImageView(image: iconSelectedImage)

        let commentTail = Interface.Image.BubbleTail.normalImage
        commentTailView = UIImageView(image: commentTail)
        super.init(normalIconView: icon, selectedIconView: iconSelected)
        addSubview(commentTailView)
        commentTailView.hidden = true
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Private
    override func updateIcon(selected selected: Bool, enabled: Bool) {
        super.updateIcon(selected: selected, enabled: enabled)
        commentTailView.hidden = !selected
    }
}

extension CommentsIcon {
    public func animate() {
        let animation = CAKeyframeAnimation()
        animation.keyPath = "position.x";
        animation.values = [0, 8.9, 9.9, 9.9, 0.1, 0, 0]
        animation.keyTimes = [0, 0.25, 0.45, 0.55, 0.75, 0.95, 0]
        animation.duration = 0.6
        animation.repeatCount = Float.infinity
        animation.additive = true
        commentTailView.layer.addAnimation(animation, forKey: "comments")
    }

    public func finishAnimation() {
        commentTailView.layer.removeAnimationForKey("comments")
    }
}
