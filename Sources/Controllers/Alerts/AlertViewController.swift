//
//  AlertViewController.swift
//  Ello
//
//  Created by Gordon Fontenot on 4/1/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

private let DesiredWidth: CGFloat = 300
private let MaxHeight = UIScreen.mainScreen().applicationFrame.height - 20

public class AlertViewController: UIViewController {
    @IBOutlet public weak var tableView: UITableView!
    @IBOutlet public weak var topPadding: NSLayoutConstraint!
    @IBOutlet public weak var leftPadding: NSLayoutConstraint!

    public var desiredSize: CGSize {
        var contentHeight = tableView.contentSize.height + totalVerticalPadding
        let height = min(contentHeight, MaxHeight)
        return CGSize(width: DesiredWidth, height: height)
    }

    public private(set) var actions: [AlertAction] = []
    private let textAlignment: NSTextAlignment

    private let headerLabel: ElloLabel = {
        let label = ElloLabel()
        label.numberOfLines = 0
        label.backgroundColor = UIColor.whiteColor()
        return label
    }()

    private var totalHorizontalPadding: CGFloat {
        return 2 * leftPadding.constant
    }

    private var totalVerticalPadding: CGFloat {
        return 2 * topPadding.constant
    }

    public init(message: String?, textAlignment: NSTextAlignment = .Center) {
        self.textAlignment = textAlignment

        super.init(nibName: "AlertViewController", bundle: NSBundle(forClass: AlertViewController.self))

        modalPresentationStyle = .Custom
        transitioningDelegate = self
        if let text = message {
            headerLabel.setLabelText(text, color: UIColor.blackColor())
        }
    }

    public required init(coder aDecoder: NSCoder) {
        fatalError("This isn't implemented")
    }
}

public extension AlertViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(AlertCell.nib(), forCellReuseIdentifier: AlertCell.reuseIdentifier())
    }

    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        tableView.scrollEnabled = (CGRectGetHeight(self.view.frame) == MaxHeight)
    }
}

extension AlertViewController {
    func addAction(action: AlertAction) {
        actions.append(action)
    }
}

extension AlertViewController: UIViewControllerTransitioningDelegate {
    public func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController!, sourceViewController source: UIViewController) -> UIPresentationController? {
        if presented != self { return .None }

        return AlertPresentationController(presentedViewController: presented, presentingViewController: presenting)
    }
}

extension AlertViewController: UITableViewDelegate {
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        dismissViewControllerAnimated(true, completion: .None)
        if let action = actions.safeValue(indexPath.row) {
            dispatch_async(dispatch_get_main_queue()) {
                action.handler?(action)
            }
        }
    }

    public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerLabel
    }

    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let size = CGSize(width: DesiredWidth - totalHorizontalPadding, height: .max)
        return headerLabel.sizeThatFits(size).height
    }
}

extension AlertViewController: UITableViewDataSource {
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return count(actions)
    }

    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(AlertCell.reuseIdentifier(), forIndexPath: indexPath) as! UITableViewCell
        let action = actions.safeValue(indexPath.row)
        let presenter = action.map { AlertCellPresenter(action: $0, textAlignment: textAlignment) }
        presenter?.configureCell(cell)
        return cell
    }
}
