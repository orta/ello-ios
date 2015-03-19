//
//  SettingsViewController.swift
//  Ello
//
//  Created by Tony DiPasquale on 3/19/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

class SettingsViewController: UITableViewController {

    @IBOutlet weak var profileImageView: UIView!
    @IBOutlet weak var profileDescription: ElloLabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    private func setupViews() {
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        navigationController?.setNavigationBarHidden(false, animated: true)
        setupProfileDescription()
    }

    private func setupProfileDescription() {
        let text = NSMutableAttributedString(attributedString: profileDescription.attributedText)
        text.addAttribute(NSForegroundColorAttributeName, value: UIColor.greyA(), range: NSRange(location: 0, length: text.length))
        profileDescription.attributedText = text
    }
}

extension SettingsViewController {
    class func instantiateFromStoryboard() -> SettingsViewController {
        return UIStoryboard(name: "Settings", bundle: NSBundle(forClass: AppDelegate.self)).instantiateInitialViewController() as SettingsViewController
    }
}
