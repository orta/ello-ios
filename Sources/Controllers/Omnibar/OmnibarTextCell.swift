//
//  OmnibarTextCell.swift
//  Ello
//
//  Created by Colin Gray on 8/18/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public class OmnibarTextCell: UITableViewCell {
    class func reuseIdentifier() -> String { return "OmnibarTextCell" }
    struct Size {
        static let margins = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        static let textMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    public let textContainer = UIView()
    public let textView: UITextView

    class func generateTextView() -> UITextView {
        let textView = UITextView()
        textView.textColor = UIColor.blackColor()
        textView.font = UIFont.typewriterFont(12)
        textView.textContainer.lineFragmentPadding = 0
        textView.backgroundColor = UIColor.clearColor()
        textView.autoresizingMask = .FlexibleHeight | .FlexibleWidth
        textView.scrollsToTop = false
        textView.scrollEnabled = false
        textView.showsHorizontalScrollIndicator = false
        textView.showsVerticalScrollIndicator = false
        return textView

    }

    public var attributedText: NSAttributedString {
        get { return textView.attributedText }
        set {
            if count(newValue.string) > 0 {
                textView.attributedText = newValue
            }
            else {
                textView.text = "Say Ello..."
            }
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        textView = OmnibarTextCell.generateTextView()
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        textContainer.backgroundColor = UIColor.grayColor()
        textView.userInteractionEnabled = false
        textView.autoresizingMask = .FlexibleHeight | .FlexibleWidth

        contentView.addSubview(textContainer)
        contentView.addSubview(textView)
    }

    required public init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        textContainer.frame = OmnibarTextCell.boundsForTextContainer(contentView.bounds)
        textView.frame = OmnibarTextCell.boundsForTextView(contentView.bounds)
    }

    override public func prepareForReuse() {
        super.prepareForReuse()
    }

    public class func boundsForTextContainer(frame: CGRect) -> CGRect {
        return frame.inset(Size.margins)
    }

    public class func boundsForTextView(frame: CGRect) -> CGRect {
        return boundsForTextContainer(frame).inset(Size.textMargins)
    }

    public class func heightForText(attributedText: NSAttributedString, tableWidth: CGFloat) -> CGFloat {
        let minHeight = CGFloat(30)
        let textWidth = tableWidth - (Size.margins.left + Size.margins.right + Size.textMargins.left + Size.textMargins.right)
        let tv = generateTextView()
        tv.attributedText = attributedText
        let tvSize = tv.sizeThatFits(CGSize(width: textWidth, height: CGFloat.max))
        let heightPadding = Size.margins.top + Size.margins.bottom + Size.textMargins.top + Size.textMargins.bottom
        let textHeight = heightPadding + round(tvSize.height)
        return max(minHeight, textHeight)
    }

}
