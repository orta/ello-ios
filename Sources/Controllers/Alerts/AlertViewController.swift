//
//  AlertViewController.swift
//  Ello
//
//  Created by Gordon Fontenot on 4/1/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

class AlertViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topPadding: NSLayoutConstraint!

    private let message: String?
    private var actions: [AlertAction] = []

    var desiredSize: CGSize {
        var size = CGSizeZero
        size.height = tableView.contentSize.height + (2 * topPadding.constant)
        size.width = 300
        return size
    }

    init(message: String?) {
        self.message = message
        super.init(nibName: "AlertViewController", bundle: .None)
        modalPresentationStyle = .Custom
        transitioningDelegate = self
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("This isn't implemented")
    }
}

extension AlertViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(AlertCell.nib(), forCellReuseIdentifier: AlertCell.reuseIdentifier())
    }
}

extension AlertViewController {
    func addAction(action: AlertAction) {
        actions.append(action)
    }
}

extension AlertViewController: UIViewControllerTransitioningDelegate {
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController!, sourceViewController source: UIViewController) -> UIPresentationController? {
        if presented != self { return .None }

        return AlertPresentationController(presentedViewController: presented, presentingViewController: presenting)
    }
}

extension AlertViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let action = actions.safeValue(indexPath.row)
        action.map { $0.handler?($0) }
        dismissViewControllerAnimated(true, completion: .None)
    }
}

extension AlertViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return count(actions)
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(AlertCell.reuseIdentifier(), forIndexPath: indexPath) as! UITableViewCell
        let action = actions.safeValue(indexPath.row)
        let presenter = action.map { AlertCellPresenter(action: $0) }
        presenter?.configureCell(cell)
        return cell
    }
}
