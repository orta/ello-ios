//
//  FollowAllCell.swift
//  Ello
//
//  Created by Colin Gray on 5/14/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

@objc
protocol FollowAllTappedResponder {
    func followAllTapped()
}

public let FollowAllCellHeight = CGFloat(77)
public class FollowAllCell: UICollectionViewCell {
    class func reuseIdentifier() -> String {
        return "FollowAllCell"
    }

    var userCount: Int = 0 {
        didSet {
            followAllButton.setTitle("Follow All (\(userCount))", forState: .Normal)
        }
    }

    lazy var followAllButton: FollowAllElloButton = {
        return FollowAllElloButton()
    }()

    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.whiteColor()

        setupFollowButton()
    }

    required public init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupFollowButton() {
        contentView.addSubview(followAllButton)
        followAllButton.frame = contentView.bounds.inset(all: 15)
        followAllButton.addTarget(self, action: Selector("followAllTappedAction"), forControlEvents: .TouchUpInside)
    }

    func followAllTappedAction() {
        let responder = targetForAction("followAllTapped", withSender: self) as? FollowAllTappedResponder
        responder?.followAllTapped()
    }
}
