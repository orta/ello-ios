//
//  AvatarButton.swift
//  Ello
//
//  Created by Ryan Boyajian on 2/5/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import SVGKit


public class AvatarButton: UIButton {
    var starIcon = UIImageView()
    var starIconHidden = false

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        let starSVG = SVGKImage(named: "star_selected.svg")
        let star = starSVG.UIImage!
        starIcon.image = star
        starIcon.frame.size = CGSize(width: 15, height: 15)
        starIcon.hidden = true
        addSubview(starIcon)
        clipsToBounds = false
    }

    func setUser(user: User?) {
        self.setDefaultImage()

        starIcon.hidden = starIconHidden || (user?.relationshipPriority != .Starred)

        if let url = user?.avatarURL {
            self.pin_setImageFromURL(url) { result in
                if result.image != nil {
                    if result.resultType != .MemoryCache {
                        self.alpha = 0
                        UIView.animateWithDuration(0.3,
                            delay:0.0,
                            options:UIViewAnimationOptions.CurveLinear,
                            animations: {
                                self.alpha = 1.0
                            }, completion: nil)
                    }
                    else {
                        self.alpha = 1.0
                    }
                }
                else {
                    self.setDefaultImage()
                }
            }
        }
    }

    func setDefaultImage() {
        pin_cancelImageDownload()
        setImage(nil, forState: .Normal)
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        if let imageView = self.imageView {
            imageView.layer.cornerRadius = imageView.bounds.size.height / CGFloat(2)
        }
        
        let naturalSize = starIcon.frame.size
        let scale = frame.width / 60
        starIcon.frame.size = CGSize(width: scale * naturalSize.width, height: scale * naturalSize.height)
        starIcon.center = CGPoint(x: frame.width, y: 0)
    }

}
