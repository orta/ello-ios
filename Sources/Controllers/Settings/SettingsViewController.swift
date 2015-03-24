//
//  SettingsViewController.swift
//  Ello
//
//  Created by Tony DiPasquale on 3/19/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

enum SettingsRow: Int {
    case CoverImage
    case ProfileImage
    case ProfileDescription
    case SensitiveSettings
    case Name
    case Bio
    case Links
    case PreferenceSettings
    case Unknown
}

class SettingsViewController: UITableViewController {

    @IBOutlet weak var profileImageView: UIView!
    @IBOutlet weak var profileDescription: ElloLabel!

    var currentUser: User?
    var sensitiveSettingsViewController: SensitiveSettingsViewController?

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

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch SettingsRow(rawValue: indexPath.row) ?? .Unknown {
        case .CoverImage: return 200
        case .ProfileImage: return 250
        case .ProfileDescription: return 130
        case .SensitiveSettings: return sensitiveSettingsViewController?.height ?? 0
        case .Name: return 97
        case .Bio: return 200
        case .Links: return 97
        case .PreferenceSettings: return 200
        case .Unknown: return 0
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier ?? "" {
        case "SensitiveSettingsSegue":
            sensitiveSettingsViewController = segue.destinationViewController as? SensitiveSettingsViewController
            sensitiveSettingsViewController?.currentUser = currentUser
            sensitiveSettingsViewController?.delegate = self
        default: break
        }
    }
}

extension SettingsViewController: SensitiveSettingsDelegate {
    func sensitiveSettingsDidUpdate() {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}

extension SettingsViewController {
    class func instantiateFromStoryboard() -> SettingsViewController {
        return UIStoryboard(name: "Settings", bundle: NSBundle(forClass: AppDelegate.self)).instantiateInitialViewController() as SettingsViewController
    }
}
