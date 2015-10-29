//
//  BlockUserModalViewController.swift
//  Ello
//
//  Created by Ryan Boyajian on 2/18/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

public class BlockUserModalViewController: BaseElloViewController {

    weak public var relationshipDelegate: RelationshipDelegate?
    // base
    @IBOutlet weak public var backgroundButton: UIButton!
    @IBOutlet weak public var modalView: UIView!
    @IBOutlet weak public var closeButton: UIButton!

    @IBOutlet weak public var titleLabel: UILabel!

    @IBOutlet weak public var muteButton: WhiteElloButton?
    @IBOutlet weak public var muteLabel: UILabel!

    @IBOutlet weak public var blockButton: WhiteElloButton?
    @IBOutlet weak public var blockLabel: UILabel!

    public var relationshipPriority: RelationshipPriority {
        didSet { selectButton(relationshipPriority) }
    }

    let userId: String
    let userAtName: String

    let changeClosure: RelationshipChangeClosure

    public var titleText: String {
        switch relationshipPriority {
        case .Mute: return "Would you like to \runmute or block \(userAtName)?"
        case .Block: return "Would you like to \rmute or unblock \(userAtName)?"
        default: return "Would you like to \rmute or block \(userAtName)?"
        }
    }

    public var muteText: String {
        return "\(userAtName) will not be able to comment on your posts. If \(userAtName) mentions you, you will not be notified."
    }

    public var blockText: String {
        return "\(userAtName) will not be able to follow you or view your profile, posts or find you in search."
    }

    required public init(userId: String, userAtName: String, relationshipPriority: RelationshipPriority, changeClosure: RelationshipChangeClosure) {
        self.userId = userId
        self.userAtName = userAtName
        self.relationshipPriority = relationshipPriority
        self.changeClosure = changeClosure
        super.init(nibName: "BlockUserModalViewController", bundle: NSBundle(forClass: BlockUserModalViewController.self))
        self.modalPresentationStyle = .Custom
        self.modalTransitionStyle = .CrossDissolve
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        styleView()
        setText()
        selectButton(relationshipPriority)
    }

    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if let superView = self.view.superview {
            self.view.center = superView.center
        }
    }

    @IBAction func blockTapped(sender: UIButton) {
        Tracker.sharedTracker.userBlocked(userId)
        handleTapped(sender, newRelationship: RelationshipPriority.Block)
    }

    @IBAction func muteTapped(sender: UIButton) {
        Tracker.sharedTracker.userMuted(userId)
        handleTapped(sender, newRelationship: RelationshipPriority.Mute)
    }

    @IBAction func closeModal(sender: UIButton?) {
        Tracker.sharedTracker.userBlockCanceled(userId)
        self.dismissViewControllerAnimated(true, completion: nil)
    }

// MARK: Internal

    private func styleView() {
        backgroundButton.backgroundColor = UIColor.modalBackground()
        modalView.backgroundColor = UIColor.redColor()
        for label in [titleLabel, muteLabel, blockLabel] {
            label.font = UIFont.typewriterFont(12)
            label.textColor = UIColor.whiteColor()
            label.lineBreakMode = .ByWordWrapping
            label.numberOfLines = 0
        }
        closeButton.setSVGImage("x_white")
    }

    private func setText() {
        muteButton?.setTitle("Mute", forState: UIControlState.Normal)
        blockButton?.setTitle("Block", forState: UIControlState.Normal)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        var attrString: NSMutableAttributedString
        for (text, label) in [titleText: titleLabel, muteText: muteLabel, blockText: blockLabel] {
            attrString = NSMutableAttributedString(string: text)
            attrString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
            label.attributedText = attrString
        }
    }

    private func handleTapped(sender: UIButton, newRelationship: RelationshipPriority) {
        let prevRelationship = relationshipPriority
        if sender.selected == true {
            relationshipPriority = .Inactive
        } else {
            relationshipPriority = newRelationship
        }

        relationshipDelegate?.updateRelationship(currentUser?.id ?? "", userId: userId, relationshipPriority: relationshipPriority) {
            (status, relationship) in
            switch status {
            case .Success:
                self.changeClosure(relationshipPriority: self.relationshipPriority)
                self.closeModal(nil)
            case .Failure:
                self.relationshipPriority = prevRelationship
                self.changeClosure(relationshipPriority: prevRelationship)
            }
        }
    }

    private func resetButtons() {
        muteButton?.selected = false
        blockButton?.selected = false
    }

    private func selectButton(relationship: RelationshipPriority) {
        resetButtons()
        switch relationship {
        case .Mute:
            muteButton?.selected = true
        case .Block:
            blockButton?.selected = true
        default: resetButtons()
        }
    }

}
