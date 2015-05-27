//
//  AlertHeaderView.swift
//  Ello
//
//  Created by Sean on 5/26/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import SVGKit

public protocol AlertHeaderDelegate: NSObjectProtocol {
    func helpTapped()
}

public class AlertHeaderView: UIView {
    @IBOutlet public weak var label: ElloLabel!
    @IBOutlet public weak var helpButton: UIButton!
    @IBOutlet public weak var helpButtonWidthConstraint: NSLayoutConstraint!

    public weak var delegate: AlertHeaderDelegate?

    public override func awakeFromNib() {
        super.awakeFromNib()
        helpButton.setImage(SVGKImage(named: "question_normal.svg").UIImage!, forState: .Normal)
        helpButtonWidthConstraint.constant = 0
    }

    public var helpButtonVisible = false {
        didSet { helpButtonWidthConstraint.constant = helpButtonVisible ? 44 : 0 }
    }

    // MARK: - IBActions
    @IBAction public func helpTapped(sender: UIButton) {
        delegate?.helpTapped()
    }
}
