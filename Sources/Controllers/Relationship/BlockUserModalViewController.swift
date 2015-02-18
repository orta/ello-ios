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
        didSet {
            selectButton(relationship)
        }
    }
    var userId: String?

    required init(relationship: Relationship) {
        self.relationship = relationship
        super.init(nibName: "BlockUserModalViewController", bundle: NSBundle(forClass: BlockUserModalViewController.self))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundButton.backgroundColor = UIColor.modalBackground()
        modalView.backgroundColor = UIColor.redColor()
        for label in [titleLabel, muteLabel, blockLabel] {
            label.font = UIFont.typewriterFont(12.0)
            label.textColor = UIColor.whiteColor()
        }
        muteButton?.setTitle("Mute", forState: UIControlState.Normal)
        blockButton?.setTitle("Block", forState: UIControlState.Normal)
        selectButton(relationship)
    }

    @IBAction func blockTapped(sender: UIButton) {
        handleTapped(sender, newRelationship: Relationship.Block)
    }

    @IBAction func muteTapped(sender: UIButton) {
        handleTapped(sender, newRelationship: Relationship.Mute)
    }

    @IBAction func closeModal(sender: UIButton) {
        self.dismissViewControllerAnimated(true) {
            println("done closing modal")
        }
    }

// MARK: Internal

    private func handleTapped(sender: UIButton, newRelationship: Relationship) {
        if sender.selected == true {
            relationship = Relationship.Inactive
        } else {
            relationship = newRelationship
        }
        if let userId = userId {
            relationshipDelegate?.relationshipTapped(userId, relationship: relationship)
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
