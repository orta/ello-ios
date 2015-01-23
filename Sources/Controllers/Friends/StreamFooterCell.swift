//
//  StreamFooterCell.swift
//  Ello
//
//  Created by Sean Dougherty on 12/10/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit
import Foundation

protocol PostbarDelegate : NSObjectProtocol {
    func viewsButtonTapped(cell:StreamFooterCell)
    func commentsButtonTapped(cell:StreamFooterCell)
    func lovesButtonTapped(cell:StreamFooterCell)
    func repostButtonTapped(cell:StreamFooterCell)
}

class StreamFooterCell: UICollectionViewCell {

    var commentsOpened = false
    weak var delegate: PostbarDelegate?

    @IBOutlet weak var viewsButton: StreamFooterButton!
    @IBOutlet weak var commentsButton: StreamFooterButton!
    @IBOutlet weak var lovesButton: StreamFooterButton!
    @IBOutlet weak var repostButton: StreamFooterButton!
    @IBOutlet weak var chevronButton: StreamFooterButton!

    var views:String? {
        get { return viewsButton.titleForState(.Normal) }
        set { viewsButton.setButtonTitle(newValue) }
    }

    var comments:String? {
        get { return commentsButton.titleForState(.Normal) }
        set { commentsButton.setButtonTitle(newValue) }
    }

    var loves:String? {
        get { return lovesButton.titleForState(.Normal) }
        set { lovesButton.setButtonTitle(newValue) }
    }

    var reposts:String? {
        get { return repostButton.titleForState(.Normal) }
        set { repostButton.setButtonTitle(newValue) }
    }

    // MARK: - IBActions

    @IBAction func viewsButtonTapped(sender: StreamFooterButton) {
        delegate?.viewsButtonTapped(self)
    }

    @IBAction func commentsButtonTapped(sender: StreamFooterButton) {
        commentsOpened = !commentsOpened
        delegate?.commentsButtonTapped(self)
    }

    @IBAction func lovesButtonTapped(sender: StreamFooterButton) {
        delegate?.lovesButtonTapped(self)
    }

    @IBAction func repostButtonTapped(sender: StreamFooterButton) {
        delegate?.repostButtonTapped(self)
    }

    @IBAction func chevronButtonTapped(sender: StreamFooterButton) {
    }
}
