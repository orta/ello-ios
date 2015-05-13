//
//  OnboardingHeaderCell.swift
//  Ello
//
//  Created by Colin Gray on 5/13/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

let OnboardingHeaderCellHeight = CGFloat(160)

public class OnboardingHeaderCell: UITableViewCell {
    class func reuseIdentifier() -> String {
        return "OnboardingHeaderCell"
    }

    var headerLabel: UILabel = {
        let label = UILabel()
        let message = NSLocalizedString("What are you interested in?", comment: "Community Selection Header text")
        label.font = UIFont.regularBoldFont(20)
        label.text = message
        label.numberOfLines = 0
        return label
    }()

    var descriptionLabel: ElloLabel = {
        let label = ElloLabel()
        let message = NSLocalizedString("Follow the Ello communities that you find most inspiring.", comment: "Community Selection Description text")
        label.font = UIFont.typewriterFont(14)
        label.setLabelText(message, color: .greyA())
        label.numberOfLines = 0
        return label
    }()

    override public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.whiteColor()
        selectionStyle = .None

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
        contentView.addSubview(descriptionLabel)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        headerLabel.frame = CGRect(x: 15, y: 15, width: self.frame.width - 30, height: 0)
        headerLabel.sizeToFit()

        descriptionLabel.frame = CGRect(x: 15, y: headerLabel.frame.maxY + 25, width: headerLabel.frame.width, height: 0)
        descriptionLabel.sizeToFit()
    }

    public func height() -> CGFloat {
        layoutIfNeeded()
        return descriptionLabel.frame.maxY + 15
    }

}
