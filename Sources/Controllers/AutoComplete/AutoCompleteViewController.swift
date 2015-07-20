//
//  AutoCompleteViewController.swift
//  Ello
//
//  Created by Sean on 6/29/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit
import Crashlytics

public protocol AutoCompleteDelegate: NSObjectProtocol {
    func itemSelected(item: AutoCompleteItem)
}

public class AutoCompleteViewController: UIViewController {
    @IBOutlet weak public var tableView: UITableView!
    public var type = AutoCompleteType.Username
    public let dataSource = AutoCompleteDataSource()
    public let service = AutoCompleteService()
    public weak var delegate: AutoCompleteDelegate?

    public convenience init(type: AutoCompleteType) {
        self.init()
        self.type = type
    }

    required public init() {
        super.init(nibName: "AutoCompleteViewController", bundle: .None)
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: View Lifecycle
extension AutoCompleteViewController {
    override public func viewDidLoad() {
        registerCells()
        style()
        super.viewDidLoad()
    }

    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.delegate = self
        tableView.dataSource = dataSource
    }

    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
}


// MARK: Public
public extension AutoCompleteViewController {

    func load(match: AutoCompleteMatch, loaded: (count: Int) -> Void) {
        service.loadResults(match.text,
            type: match.type,
            success: { (results, responseConfig) in
                println("match = \(match.text)\n")
                self.dataSource.items = results.map { AutoCompleteItem(result: $0, type: self.type, match: match) }
                self.tableView.reloadData()
                loaded(count: self.dataSource.items.count)
        }, failure: showAutoCompleteLoadFailure)
    }
    
    func showAutoCompleteLoadFailure(error: NSError, statusCode:Int?) {
        let message = NSLocalizedString("Something went wrong. Thank you for your patience with Ello Beta!", comment: "Initial stream load failure")
        let alertController = AlertViewController(message: message)
        let action = AlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .Dark, handler: nil)
        alertController.addAction(action)
        logPresentingAlert("AutoCompleteViewController")
        presentViewController(alertController, animated: true) {
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
}

// MARK: UITableViewDelegate
extension AutoCompleteViewController: UITableViewDelegate {
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let item = dataSource.itemForIndexPath(indexPath) {
            delegate?.itemSelected(item)
        }
    }
}


// MARK: Private
private extension AutoCompleteViewController {
    func registerCells() {
        tableView.registerNib(AutoCompleteCell.nib(), forCellReuseIdentifier: AutoCompleteCell.reuseIdentifier())
    }

    func style() {
        tableView.backgroundColor = UIColor.blackColor()
    }
}
