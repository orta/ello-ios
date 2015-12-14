//
//  AlertHeaderView.swift
//  Ello
//
//  Created by Sean on 5/26/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public protocol AlertHeaderDelegate: NSObjectProtocol {
    func helpTapped()
}

public class AlertHeaderView: UIView {
    public weak var label: ElloLabel!
    @IBOutlet public weak var helpButton: UIButton!
    @IBOutlet public weak var helpButtonWidthConstraint: NSLayoutConstraint!

    public weak var delegate: AlertHeaderDelegate?

    public override func awakeFromNib() {
        super.awakeFromNib()
        helpButton.setImage(.Question, imageStyle: .Normal, forState: .Normal)
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
