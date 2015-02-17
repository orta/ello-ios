//
//  RelationshipView.swift
//  Ello
//
//  Created by Ryan Boyajian on 2/16/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

enum Relationship: String {
    case Friend = "friend"
    case Noise = "noise"
    case Block = "block"
    case Mute = "mute"
    case Inactive = "inactive"
    case None = "none"
    case Null = "null"
    case Me = "self"

    static let all = [Friend, Noise, Block, Mute, Inactive, None, Null, Me]
}

protocol RelationshipDelegate: NSObjectProtocol {
    func relationshipTapped(userId: String, relationship: Relationship)
}

class RelationshipView: UIView {

    var friendButton: UIButton
    var noiseButton: UIButton
    var blockButton: UIButton?
    weak var relationshipDelegate: RelationshipDelegate?
    var userId: String
    let backgroundColorNormal = UIColor.whiteColor()
    let backgroundColorSelected = UIColor(hex:0xAAAAAA)
    let backgroundColorBlock = UIColor.redColor()

    var relationship:Relationship? {
        didSet {
            selectButton(relationship!)
        }
    }

    required init(coder: NSCoder) {
        self.friendButton = UIButton()
        self.noiseButton = UIButton()
        self.userId = ""
        super.init(coder: coder)
        buildLargeButtons()
        addTargets()
    }

    @IBAction func friendTapped(sender: UIButton) {
        if sender.selected == true { return }
        selectButton(Relationship.Friend)
        relationshipDelegate?.relationshipTapped(userId, relationship: Relationship.Friend)
    }

    @IBAction func noiseTapped(sender: UIButton) {
        if sender.selected == true { return }
        selectButton(Relationship.Noise)
        relationshipDelegate?.relationshipTapped(userId, relationship: Relationship.Noise)
    }

    @IBAction func blockTapped(sender: UIButton) {
        if sender.selected == true { return }
        selectButton(Relationship.Block)
        relationshipDelegate?.relationshipTapped(userId, relationship: Relationship.Noise)
    }

// MARK: Internal

    private func resetButtons() {
        friendButton.selected = false
        friendButton.backgroundColor = backgroundColorNormal
        noiseButton.selected = false
        noiseButton.backgroundColor = backgroundColorNormal
        blockButton?.selected = false
        blockButton?.backgroundColor = backgroundColorNormal
        blockButton?.layer.borderColor = backgroundColorSelected.CGColor
    }

    private func selectButton(relationship: Relationship) {
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
        default: println("relationship: \(relationship.rawValue)")
        }
    }

    private func buildLargeButtons() {
        let wv = 68
        // friend
        styleTitleButton(friendButton, label: "Friend")
        friendButton.frame = CGRect(x: 0, y: 0, width: wv, height: 30)
        // noise
        styleTitleButton(noiseButton, label: "Noise")
        noiseButton.frame = CGRect(x: wv - 1, y: 0, width: wv, height: 30)
        // block/mute
        blockButton = UIButton()
        styleIconButton(blockButton!)
        blockButton!.frame = CGRect(x: wv * 2 - 2, y: 0, width: 30, height: 30)
    }

    private func addTargets() {
        friendButton.addTarget(self, action: "friendTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        noiseButton.addTarget(self, action: "noiseTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        blockButton?.addTarget(self, action: "blockTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        addSubview(friendButton)
        addSubview(noiseButton)
        if let blockButton = blockButton {
            addSubview(blockButton)
        }
    }

    private func buildSmallButtons() {
        let wv = 30
        // friend
        styleTitleButton(friendButton, label: "F")
        friendButton.frame = CGRect(x: 0, y: 0, width: wv, height: 30)

        // noise
        styleTitleButton(noiseButton, label: "N")
        noiseButton.frame = CGRect(x: wv - 1, y: 0, width: wv, height: 30)
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

    private func styleIconButton(button: UIButton) {
        styleBaseButton(button)
    }
}

class RelationshipController: NSObject, RelationshipDelegate {

    func relationshipTapped(userId: String, relationship: Relationship) {
        println("userId: \(userId) relationship: \(relationship.rawValue)")
    }

}