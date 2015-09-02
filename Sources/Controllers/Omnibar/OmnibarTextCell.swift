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
        static let textMargins = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        static let minHeight = CGFloat(100)
    }

    public let textView: UITextView

    class func generateTextView() -> UITextView {
        let textView = UITextView()
        textView.textColor = UIColor.blackColor()
        textView.font = UIFont.typewriterEditorFont(12)
        textView.textContainer.lineFragmentPadding = 0
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
                textView.attributedText = ElloAttributedString.style("Add more text...")
            }
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        textView = OmnibarTextCell.generateTextView()
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        textView.userInteractionEnabled = false
        textView.autoresizingMask = .FlexibleHeight | .FlexibleWidth
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.whiteColor()
        self.backgroundView = backgroundView

        contentView.addSubview(textView)
    }

    required public init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        textView.frame = OmnibarTextCell.boundsForTextView(contentView.bounds)
    }

    public class func boundsForTextView(frame: CGRect) -> CGRect {
        return frame.inset(Size.textMargins)
    }

    public class func heightForText(attributedText: NSAttributedString, tableWidth: CGFloat) -> CGFloat {
        let textWidth = tableWidth - (Size.textMargins.left + Size.textMargins.right)
        let tv = generateTextView()
        tv.attributedText = attributedText
        let tvSize = tv.sizeThatFits(CGSize(width: textWidth, height: CGFloat.max))
        let heightPadding = Size.textMargins.top + Size.textMargins.bottom
        let textHeight = heightPadding + round(tvSize.height)
        return max(Size.minHeight, textHeight)
    }

}
