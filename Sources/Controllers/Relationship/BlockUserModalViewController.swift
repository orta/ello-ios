//
//  BlockUserModalViewController.swift
//  Ello
//
//  Created by Ryan Boyajian on 2/18/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation


class BlockUserModalViewController: BaseElloViewController {

    weak var relationshipDelegate: RelationshipDelegate?
    // base
    @IBOutlet weak var backgroundButton: UIButton!
    @IBOutlet weak var modalView: UIView!
    @IBOutlet weak var closeButton: UIButton!

    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var muteButton: WhiteElloButton?
    @IBOutlet weak var muteLabel: UILabel!

    @IBOutlet weak var blockButton: WhiteElloButton?
    @IBOutlet weak var blockLabel: UILabel!
                    
    var relationship: Relationship {
        didSet { selectButton(relationship) }
    }

    let userId: String
    let userAtName: String

    let changeClosure: RelationshipChangeClosure

    var titleText: String {
        switch relationship {
        case .Mute: return "Would you like to \runmute or block \(userAtName)?"
        case .Block: return "Would you like to \rmute or unblock \(userAtName)?"
        default: return "Would you like to \rmute or block \(userAtName)?"
        }
    }

    var muteText: String {
        return "\(userAtName) will not be able to comment on your posts. If \(userAtName) mentions you, you will not be notified."
    }

    var blockText: String {
        return "\(userAtName) will not be able to follow you or view your profile, posts or find you in search."
    }

    required init(userId: String, userAtName: String, relationship: Relationship, changeClosure: RelationshipChangeClosure) {
        self.userId = userId
        self.userAtName = userAtName
        self.relationship = relationship
        self.changeClosure = changeClosure
        super.init(nibName: "BlockUserModalViewController", bundle: NSBundle(forClass: BlockUserModalViewController.self))
        self.modalPresentationStyle = .Custom
        self.modalTransitionStyle = .CrossDissolve
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        styleView()
        setText()
        selectButton(relationship)
    }

    @IBAction func blockTapped(sender: UIButton) {
        handleTapped(sender, newRelationship: Relationship.Block)
    }

    @IBAction func muteTapped(sender: UIButton) {
        handleTapped(sender, newRelationship: Relationship.Mute)
    }

    @IBAction func closeModal(sender: UIButton?) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

// MARK: Internal

    private func styleView() {
        backgroundButton.backgroundColor = UIColor.modalBackground()
        modalView.backgroundColor = UIColor.redColor()
        for label in [titleLabel, muteLabel, blockLabel] {
            label.font = UIFont.typewriterFont(12.0)
            label.textColor = UIColor.whiteColor()
            label.lineBreakMode = .ByWordWrapping
            label.numberOfLines = 0
        }
    }

    private func setText() {
        muteButton?.setTitle("Mute", forState: UIControlState.Normal)
        blockButton?.setTitle("Block", forState: UIControlState.Normal)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 12
        var attrString: NSMutableAttributedString
        for (text, label) in [titleText: titleLabel, muteText: muteLabel, blockText: blockLabel] {
            attrString = NSMutableAttributedString(string: text)
            attrString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
            label.attributedText = attrString
        }
    }

    private func handleTapped(sender: UIButton, newRelationship: Relationship) {
        let prevRelationship = relationship
        if sender.selected == true {
            relationship = Relationship.Inactive
        } else {
            relationship = newRelationship
        }
        relationshipDelegate?.relationshipTapped(userId, relationship: relationship) {
            [unowned self] status in
            switch status {
            case .Success:
                self.changeClosure(relationship: self.relationship)
                self.closeModal(nil)
            case .Failure:
                self.relationship = prevRelationship
            }
        }
    }

    private func resetButtons() {
        muteButton?.selected = false
        blockButton?.selected = false
    }

    private func selectButton(relationship: Relationship) {
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
