//
//  OnboardingHeaderCell.swift
//  Ello
//
//  Created by Colin Gray on 5/13/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//


public class OnboardingHeaderView: UIView {
    lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.regularBoldFont(20)
        label.numberOfLines = 0
        return label
    }()

    lazy var messageLabel: ElloSizeableLabel = {
        let label = ElloSizeableLabel()
        label.font = UIFont.typewriterFont(14)
        label.numberOfLines = 0
        return label
    }()

    var header: String {
        get { return headerLabel.text ?? "" }
        set {
            headerLabel.text = newValue
            setNeedsLayout()
        }
    }

    var message: String {
        get { return messageLabel.text ?? "" }
        set {
            messageLabel.setLabelText(newValue, color: .greyA())
            setNeedsLayout()
        }
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(headerLabel)
        addSubview(messageLabel)
    }

    required public init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        var labelWidth = self.frame.width - 30
        headerLabel.frame = CGRect(x: 15, y: 24, width: labelWidth, height: 0)
        headerLabel.sizeToFit()

        messageLabel.frame = CGRect(x: 15, y: headerLabel.frame.maxY + 25, width: labelWidth, height: 0)
        messageLabel.sizeToFit()
    }

    override public func sizeToFit() {
        super.sizeToFit()
        layoutIfNeeded()
        frame.size.height = intrinsicContentSize().height
    }

    override public func intrinsicContentSize() -> CGSize {
        layoutIfNeeded()
        return CGSize(width: frame.width, height: messageLabel.frame.maxY + 15)
    }

}


public class OnboardingHeaderCell: UICollectionViewCell {
    class func reuseIdentifier() -> String {
        return "OnboardingHeaderCell"
    }

    lazy var onboardingHeaderView: OnboardingHeaderView = {
        let view = OnboardingHeaderView()
        view.frame = self.frame
        view.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        return view
    }()
    var headerLabel: UILabel { return onboardingHeaderView.headerLabel }
    var messageLabel: ElloLabel { return onboardingHeaderView.messageLabel }

    var header: String {
        get { return headerLabel.text ?? "" }
        set {
            headerLabel.text = newValue
        }
    }

    var message: String {
        get { return messageLabel.text ?? "" }
        set {
            messageLabel.setLabelText(newValue, color: .greyA())
        }
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.whiteColor()

        setupHeaderView()
    }

    required public init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupHeaderView() {
        contentView.addSubview(onboardingHeaderView)
    }

    public func height() -> CGFloat {
        return onboardingHeaderView.intrinsicContentSize().height
    }

}
