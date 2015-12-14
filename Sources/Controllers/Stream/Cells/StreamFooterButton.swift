//
//  StreamFooterButton.swift
//  Ello
//
//  Created by Sean Dougherty on 12/10/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

public class StreamFooterButton: UIButton {

    var attributedText:NSMutableAttributedString = NSMutableAttributedString(string: "")

    func setButtonTitleWithPadding(title: String?, titlePadding: CGFloat = 4.0, contentPadding: CGFloat = 5.0) {

        if let title = title {
            setButtonTitle(title, color: UIColor.greyA(), forState: .Normal)
            setButtonTitle(title, color: UIColor.blackColor(), forState: .Highlighted)
            setButtonTitle(title, color: UIColor.blackColor(), forState: .Selected)
        }

        let titleInsets = UIEdgeInsetsMake(0.0, titlePadding, 0.0, -(titlePadding));

        let contentInsets = UIEdgeInsetsMake(0.0, contentPadding, 0.0, contentPadding)

        titleEdgeInsets = titleInsets
        contentEdgeInsets = contentInsets
        sizeToFit()
    }

    private func setButtonTitle(title: String, color: UIColor, forState state: UIControlState) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .Center

        let attributes = [
            NSFontAttributeName : UIFont.defaultFont(),
            NSForegroundColorAttributeName : color,
            NSParagraphStyleAttributeName : paragraphStyle
        ]
        attributedText = NSMutableAttributedString(string: title, attributes: attributes)

        contentHorizontalAlignment = .Center
        self.titleLabel?.textAlignment = .Center
        self.setAttributedTitle(attributedText, forState: state)
    }

    override public func sizeThatFits(size: CGSize) -> CGSize {
        let size = super.sizeThatFits(size)
        return CGSizeMake(max(44.0, size.width), 44.0)
    }
}
