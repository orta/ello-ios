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
        static let margins = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
        static let textMargins = UIEdgeInsets(top: 22, left: 30, bottom: 9, right: 30)
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
        set { textView.attributedText = newValue }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        textView = OmnibarTextCell.generateTextView()
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        textContainer.backgroundColor = UIColor.greyE5()
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
        return frame.inset(top: 0, left: Size.margins.left, bottom: 0, right: Size.margins.right)
    }

    public class func boundsForTextView(frame: CGRect) -> CGRect {
        return boundsForTextContainer(frame).inset(Size.textMargins)
    }

    public class func heightForText(attributedText: NSAttributedString, tableWidth: CGFloat) -> CGFloat {
        let minHeight = CGFloat(100)
        let textWidth = tableWidth - (Size.margins.left + Size.margins.right + Size.textMargins.left + Size.textMargins.right)
        let heightPadding = Size.margins.top + Size.margins.bottom + Size.textMargins.top + Size.textMargins.bottom
        // let textHeight = heightPadding + round(attributedText.boundingRectWithSize(CGSize(width: textWidth, height: 0), options: .UsesLineFragmentOrigin | .UsesFontLeading, context: nil).size.height)
        let tv = generateTextView()
        tv.attributedText = attributedText
        tv.sizeToFit()
        let thisSize = tv.frame.size
        let textHeight = heightPadding + thisSize.height
        return max(minHeight, textHeight)
    }

}
