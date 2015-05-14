//
//  OnboardingHeaderCell.swift
//  Ello
//
//  Created by Colin Gray on 5/13/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

let OnboardingHeaderCellHeight = CGFloat(160)


public struct OnboardingHeaderCellPresenter {

    static func configure(
        cell:UICollectionViewCell,
        streamCellItem:StreamCellItem,
        streamKind: StreamKind,
        indexPath: NSIndexPath,
        currentUser: User?)
    {
        if let cell = cell as? OnboardingHeaderCell {
            cell.header = NSLocalizedString("What are you interested in?", comment: "Community Selection Header text")
            cell.message = NSLocalizedString("Follow the Ello communities that you find most inspiring.", comment: "Community Selection Description text")
        }
    }
}


public class OnboardingHeaderCell: UICollectionViewCell {
    class func reuseIdentifier() -> String {
        return "OnboardingHeaderCell"
    }

    var headerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.regularBoldFont(20)
        label.numberOfLines = 0
        return label
    }()

    var messageLabel: ElloLabel = {
        let label = ElloLabel()
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
        self.backgroundColor = UIColor.whiteColor()

        setupHeaderLabel()
        setupDescriptionLabel()
    }

    required public init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupHeaderLabel() {
        contentView.addSubview(headerLabel)
    }

    private func setupDescriptionLabel() {
        contentView.addSubview(messageLabel)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        headerLabel.frame = CGRect(x: 15, y: 15, width: self.frame.width - 30, height: 0)
        headerLabel.sizeToFit()

        messageLabel.frame = CGRect(x: 15, y: headerLabel.frame.maxY + 25, width: headerLabel.frame.width, height: 0)
        messageLabel.sizeToFit()
    }

    public func height() -> CGFloat {
        layoutIfNeeded()
        return messageLabel.frame.maxY + 15
    }

}
