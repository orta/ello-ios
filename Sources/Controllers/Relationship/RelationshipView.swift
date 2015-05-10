//
//  RelationshipView.swift
//  Ello
//
//  Created by Ryan Boyajian on 2/16/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

public class RelationshipView: UIView {
    public var userId: String
    public var userAtName: String
    let backgroundColorNormal = UIColor.whiteColor()
    let backgroundColorSelected = UIColor.greyA()
    let backgroundColorBlock = UIColor.redColor()
    public var friendButton: UIButton
    public var noiseButton: UIButton
    public var blockButton: UIButton?
    public weak var relationshipDelegate: RelationshipDelegate?
    public var relationship:RelationshipPriority? {
        didSet {
            selectButton(relationship!)
        }
    }

    required public init(coder: NSCoder) {
        self.friendButton = UIButton()
        self.noiseButton = UIButton()
        self.userId = ""
        self.userAtName = ""
        super.init(coder: coder)
    }

    @IBAction func friendTapped(sender: UIButton) {
        Tracker.sharedTracker.friendAdded()
        handleTapped(sender, newRelationship: RelationshipPriority.Friend)
    }

    @IBAction func noiseTapped(sender: UIButton) {
        Tracker.sharedTracker.noiseAdded()
        handleTapped(sender, newRelationship: RelationshipPriority.Noise)
    }

    @IBAction func blockTapped(sender: UIButton) {
        relationshipDelegate?.launchBlockModal(userId, userAtName: userAtName, relationship: relationship!) {
            [unowned self] relationship in
            self.relationship = relationship
        }
    }

// MARK: Internal

    private func handleTapped(sender: UIButton, newRelationship: RelationshipPriority) {
        let prevRelationship = relationship
        if sender.selected == true {
            relationship = RelationshipPriority.Inactive
        } else {
            relationship = newRelationship
        }
        relationshipDelegate?.relationshipTapped(userId, relationship: relationship!) {
            [unowned self] (status, relationship) in
            if status == .Failure {
                self.relationship = prevRelationship
            }
        }
    }

    private func resetButtons() {
        friendButton.selected = false
        friendButton.backgroundColor = backgroundColorNormal
        noiseButton.selected = false
        noiseButton.backgroundColor = backgroundColorNormal
        blockButton?.selected = false
        blockButton?.backgroundColor = backgroundColorNormal
        blockButton?.layer.borderColor = backgroundColorSelected.CGColor
    }

    private func selectButton(relationship: RelationshipPriority) {
        resetButtons()
        switch relationship {
        case .Friend:
            friendButton.selected = true
            friendButton.backgroundColor = backgroundColorSelected
        case .Noise:
            noiseButton.selected = true
            noiseButton.backgroundColor = backgroundColorSelected
        case .Mute, .Block:
            blockButton?.selected = true
            blockButton?.backgroundColor = backgroundColorBlock
            blockButton?.layer.borderColor = backgroundColorBlock.CGColor
        default: resetButtons()
        }
    }

    public func buildLargeButtons() {
        let wv = 68
        // friend
        styleTitleButton(friendButton, label: "Friend")
        friendButton.frame = CGRect(x: 0, y: 0, width: wv, height: 30)
        // noise
        styleTitleButton(noiseButton, label: "Noise")
        noiseButton.frame = CGRect(x: wv - 1, y: 0, width: wv, height: 30)
        // block/mute
        blockButton = UIButton()
        styleIconButton(blockButton!, named: "danger")
        blockButton!.frame = CGRect(x: wv * 2 - 2, y: 0, width: 30, height: 30)
        addTargets()
    }

    public func buildSmallButtons() {
        let wv = 30
        // friend
        styleTitleButton(friendButton, label: "F")
        friendButton.frame = CGRect(x: 0, y: 0, width: wv, height: 30)

        // noise
        styleTitleButton(noiseButton, label: "N")
        noiseButton.frame = CGRect(x: wv - 1, y: 0, width: wv, height: 30)
        addTargets()
    }

    private func addTargets() {
        friendButton.addTarget(self, action: Selector("friendTapped:"), forControlEvents: UIControlEvents.TouchUpInside)
        noiseButton.addTarget(self, action: Selector("noiseTapped:"), forControlEvents: UIControlEvents.TouchUpInside)
        blockButton?.addTarget(self, action: Selector("blockTapped:"), forControlEvents: UIControlEvents.TouchUpInside)
        addSubview(friendButton)
        addSubview(noiseButton)
        if let blockButton = blockButton {
            addSubview(blockButton)
        }
    }

    private func styleBaseButton(button: UIButton) {
        button.layer.borderWidth = 1
        button.layer.borderColor = backgroundColorSelected.CGColor
        button.backgroundColor = backgroundColorNormal
    }

    private func styleTitleButton(button: UIButton, label: String) {
        styleBaseButton(button)
        button.titleLabel?.font = UIFont.typewriterFont(12.0)
        button.setTitle(label, forState: UIControlState.Normal)
        button.setTitle(label, forState: UIControlState.Selected)
        button.setTitleColor(backgroundColorSelected, forState: UIControlState.Normal)
        button.setTitleColor(backgroundColorNormal, forState: UIControlState.Selected)
    }

    private func styleIconButton(button: UIButton, named: String) {
        styleBaseButton(button)
        button.setSVGImages(named)
    }
}
