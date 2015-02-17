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

    var relationship:Relationship {
        get {
            return self.relationship
        }
        set(relationship) {
            switch relationship {
            default: println(relationship)
            }
        }
    }

    required init(coder: NSCoder) {
        self.friendButton = UIButton()
        self.noiseButton = UIButton()
        self.userId = ""
        super.init(coder: coder)
        buildLargeButtons()
    }

    @IBAction func friendTapped(sender: UIButton) {
        println("friendTapped")
        relationshipDelegate?.relationshipTapped(userId, relationship: Relationship.Friend)
    }

    @IBAction func noiseTapped(sender: UIButton) {
        println("noiseTapped")
        relationshipDelegate?.relationshipTapped(userId, relationship: Relationship.Noise)
    }

    @IBAction func blockTapped(sender: UIButton) {
        println("blockTapped, launch block modal")
    }

// MARK: Internal

    private func buildLargeButtons() {
        let wv = 68
        styleButton(friendButton, label: "Friend", action: "friendTapped:")
        friendButton.frame = CGRect(x: 0, y: 0, width: wv, height: 30)
        styleButton(noiseButton, label: "Noise", action: "noiseTapped:")
        noiseButton.frame = CGRect(x: wv - 1, y: 0, width: wv, height: 30)
    }

    private func buildSmallButtons() {
        let wv = 30
        styleButton(friendButton, label: "F", action: "friendTapped:")
        friendButton.frame = CGRect(x: 0, y: 0, width: wv, height: 30)
        styleButton(noiseButton, label: "N", action: "noiseTapped:")
        noiseButton.frame = CGRect(x: wv - 1, y: 0, width: wv, height: 30)
    }

    private func styleButton(button: UIButton, label: String, action: Selector, state: UIControlState = UIControlState.Normal) {
        button.layer.borderWidth = 1
        button.setTitle(label, forState: state)
        button.layer.borderColor = UIColor.grayColor().CGColor
        button.titleLabel?.font = UIFont.typewriterFont(12.0)
        if state == UIControlState.Normal {
            button.setTitleColor(UIColor.grayColor(), forState: state)
            button.backgroundColor = UIColor.whiteColor()
        }
        else {
            button.setTitleColor(UIColor.whiteColor(), forState: state)
            button.backgroundColor = UIColor.grayColor()
        }
        button.addTarget(self, action: action, forControlEvents: UIControlEvents.TouchUpInside)
        addSubview(button)
    }
}

class RelationshipController: NSObject, RelationshipDelegate {

    func relationshipTapped(userId: String, relationship: Relationship) {
        println("userId: \(userId) relationship: \(relationship.rawValue)")
    }

}