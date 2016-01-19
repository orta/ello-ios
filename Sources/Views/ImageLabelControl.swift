//
//  ImageLabelControl.swift
//  Ello
//
//  Created by Sean on 4/29/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//
import ElloUIFonts

public class ImageLabelControl: UIControl {

    public var title: String? {
        get { return self.attributedNormalTitle?.string }
        set {
            if let value = newValue where label.text != value {
                attributedNormalTitle = attributedText(value, color: .greyA())
                attributedSelectedTitle = attributedText(value, color: .blackColor())
                updateLayout()
            }
        }
    }

    override public var selected: Bool {
        didSet {
            icon.selected = selected
            if !highlighted {
                label.attributedText = selected ? attributedSelectedTitle : attributedNormalTitle
            }

        }
    }

    override public var highlighted: Bool {
        didSet {
            icon.highlighted = highlighted
            if !selected {
                label.attributedText = highlighted ? attributedSelectedTitle : attributedNormalTitle
            }
        }
    }

    override public var enabled: Bool {
        didSet {
            icon.enabled = enabled
        }
    }

    let innerPadding: CGFloat = 5
    let outerPadding: CGFloat = 5
    let minWidth: CGFloat = 44
    let height: CGFloat = 44
    let titleFont = UIFont.defaultFont()
    let contentContainer = UIView(frame: CGRectZero)
    let label = UILabel(frame: CGRectZero)
    let button = UIButton(frame: CGRectZero)
    var icon: ImageLabelAnimatable
    var attributedNormalTitle: NSAttributedString!
    var attributedSelectedTitle: NSAttributedString!

    // MARK: Initializers

    public init(icon: ImageLabelAnimatable, title: String) {
        self.icon = icon
        super.init(frame: CGRectZero)
        addSubviews()
        addTargets()
        self.title = title
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public

    public func animate() {
        self.icon.animate?()
    }

    public func finishAnimation() {
        self.icon.finishAnimation?()
    }

    // MARK: IBActions

    @IBAction func buttonTouchUpInside(sender: ImageLabelControl) {
        sendActionsForControlEvents(.TouchUpInside)
        highlighted = false
    }

    @IBAction func buttonTouchUpOutside(sender: ImageLabelControl) {
        sendActionsForControlEvents(.TouchUpOutside)
        highlighted = false
    }

    @IBAction func buttonTouchDown(sender: ImageLabelControl) {
        sendActionsForControlEvents(.TouchDown)
        highlighted = true
    }

    // MARK: Private

    private func addSubviews() {
        addSubview(contentContainer)
        addSubview(button)
        contentContainer.addSubview(icon.view)
        contentContainer.addSubview(label)
    }

    private func addTargets() {
        button.addTarget(self, action: Selector("buttonTouchUpInside:"), forControlEvents: .TouchUpInside)
        button.addTarget(self, action: Selector("buttonTouchDown:"), forControlEvents: [.TouchDown, .TouchDragEnter])
        button.addTarget(self, action: Selector("buttonTouchUpOutside:"), forControlEvents: [.TouchCancel, .TouchDragExit])
    }

    private func updateLayout() {
        label.attributedText = attributedNormalTitle
        label.sizeToFit()
        let textWidth = attributedNormalTitle.widthForHeight(0)
        let contentWidth = textWidth == 0 ?
            icon.view.frame.width :
            icon.view.frame.width + textWidth + innerPadding

        var width: CGFloat =  contentWidth + outerPadding * 2

        // force a minimum width of 44 pts
        width = max(width, minWidth)

        self.frame.size.width = width
        self.frame.size.height = height

        let iconViewY: CGFloat = height / 2 - icon.view.frame.size.height / 2
        icon.view.frame.origin.y = iconViewY

        let contentX: CGFloat = width / 2 - contentWidth / 2
        contentContainer.frame =
            CGRect(
                x: contentX,
                y: 0,
                width: contentWidth,
                height: height
            )

        button.frame.size.width = width
        button.frame.size.height = height

        label.frame.origin.x = icon.view.frame.origin.x + icon.view.frame.width + innerPadding
        label.frame.origin.y = height / 2 - label.frame.size.height / 2
    }

    private func attributedText(title: String, color: UIColor) -> NSAttributedString {
        let attributed = NSMutableAttributedString(string: title)
        let range = NSRange(location: 0, length: title.characters.count)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .Left

        let attributes = [
            NSFontAttributeName : titleFont,
            NSForegroundColorAttributeName : color,
            NSParagraphStyleAttributeName : paragraphStyle
        ]
        attributed.addAttributes(attributes, range: range)
        return attributed
    }
}
