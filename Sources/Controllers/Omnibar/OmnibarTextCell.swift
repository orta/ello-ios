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
        static let textMargins = UIEdgeInsets(top: 11, left: 15, bottom: 11, right: 15)
        static let minHeight = CGFloat(44)
        static let maxEditingHeight = CGFloat(77)
    }

    public let textView: UITextView

    class func generateTextView() -> UITextView {
        let textView = UITextView()
        textView.textColor = UIColor.blackColor()
        textView.font = UIFont.typewriterEditorFont(12)
        textView.textContainerInset = UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)
        textView.textContainer.lineFragmentPadding = 0
        textView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        textView.scrollsToTop = false
        textView.scrollEnabled = false
        textView.showsHorizontalScrollIndicator = false
        textView.showsVerticalScrollIndicator = false
        return textView

    }

    public var attributedText: NSAttributedString {
        get { return textView.attributedText }
        set {
            if newValue.string.characters.count > 0 {
                textView.attributedText = newValue
            }
            else {
                textView.attributedText = ElloAttributedString.style("Add more text...", [NSForegroundColorAttributeName: UIColor.greyC()])
            }
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        textView = OmnibarTextCell.generateTextView()
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        textView.userInteractionEnabled = false
        textView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
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

    public class func heightForText(attributedText: NSAttributedString, tableWidth: CGFloat, editing: Bool) -> CGFloat {
        var textWidth = tableWidth - (Size.textMargins.left + Size.textMargins.right)
        if editing {
            textWidth -= 80
        }

        let tv = generateTextView()
        tv.attributedText = attributedText
        let tvSize = tv.sizeThatFits(CGSize(width: textWidth, height: CGFloat.max))
        // adding a magic 1, for rare "off by 1" height calculations.
        let heightPadding = Size.textMargins.top + Size.textMargins.bottom + 1
        let textHeight = heightPadding + ceil(tvSize.height)

        let reasonableHeight = max(Size.minHeight, textHeight)
        if editing {
            return min(Size.maxEditingHeight, reasonableHeight)
        }
        return reasonableHeight
    }

}
