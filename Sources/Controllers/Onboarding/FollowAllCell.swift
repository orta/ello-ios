//
//  FollowAllCell.swift
//  Ello
//
//  Created by Colin Gray on 5/14/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

@objc
protocol FollowAllButtonResponder {
    func onFollowAll()
}

public class FollowAllCell: UICollectionViewCell {
    class func reuseIdentifier() -> String {
        return "FollowAllCell"
    }

    var followedCount: Int = 0 { didSet { updateTitle() } }
    var userCount: Int = 0 { didSet { updateTitle() } }
    private func updateTitle() {
        followAllButton.selected = (followedCount == userCount)
        if followedCount == userCount {
            followAllButton.setTitle("Following (\(followedCount))", forState: .Normal)
        }
        else {
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
        followAllButton.addTarget(self, action: Selector("followAllTapped"), forControlEvents: .TouchUpInside)
    }

    func followAllTapped() {
        let responder = targetForAction("onFollowAll", withSender: self) as? FollowAllButtonResponder
        responder?.onFollowAll()
    }
}
