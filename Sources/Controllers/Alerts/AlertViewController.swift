//
//  AlertViewController.swift
//  Ello
//
//  Created by Gordon Fontenot on 4/1/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

private let DesiredWidth: CGFloat = 300
private let MaxHeight = UIScreen.mainScreen().applicationFrame.height - 20

public enum AlertType {
    case Normal
    case Danger

    var backgroundColor: UIColor {
        switch self {
            case .Danger: return .redColor()
            default:      return .whiteColor()
        }
    }
}

public class AlertViewController: UIViewController {
    @IBOutlet public weak var tableView: UITableView!
    @IBOutlet public weak var topPadding: NSLayoutConstraint!
    @IBOutlet public weak var leftPadding: NSLayoutConstraint!

    // assign a contentView to show a message or spinner.  The contentView frame
    // size must be set.
    public var contentView: UIView? {
        willSet { willSetContentView() }
        didSet { didSetContentView() }
    }

    public var desiredSize: CGSize {
        if let contentView = contentView {
            return contentView.frame.size
        }
        else {
            var contentHeight = tableView.contentSize.height + totalVerticalPadding
            let height = min(contentHeight, MaxHeight)
            return CGSize(width: DesiredWidth, height: height)
        }
    }

    public var dismissable: Bool = true
    public var autoDismiss: Bool = true

    public private(set) var actions: [AlertAction] = []
    private let textAlignment: NSTextAlignment
    public var type: AlertType = .Normal {
        didSet {
            let backgroundColor = type.backgroundColor
            view.backgroundColor = backgroundColor
            tableView.backgroundColor = backgroundColor
            headerLabel.backgroundColor = backgroundColor
            tableView.reloadData()
        }
    }

    public var message: String {
        get { return headerLabel.text ?? "" }
        set(text) { headerLabel.setLabelText(text, color: UIColor.blackColor())}
    }

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

    public init(message: String?, textAlignment: NSTextAlignment = .Center, type: AlertType = .Normal) {
        self.textAlignment = textAlignment
        super.init(nibName: "AlertViewController", bundle: NSBundle(forClass: AlertViewController.self))

        modalPresentationStyle = .Custom
        transitioningDelegate = self
        if let text = message {
            headerLabel.setLabelText(text, color: UIColor.blackColor())
        }

        view.backgroundColor = type.backgroundColor
        tableView.backgroundColor = type.backgroundColor
        headerLabel.backgroundColor = type.backgroundColor
        self.type = type
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

    public func dismiss(animated: Bool = true, completion: (()->())? = .None) {
        dismissViewControllerAnimated(animated, completion: completion)
    }
}

extension AlertViewController {
    func addAction(action: AlertAction) {
        actions.append(action)
        tableView.reloadData()
    }

    func resetActions() {
        actions = []
        tableView.reloadData()
    }
}

extension AlertViewController {
    private func willSetContentView() {
        if let contentView = self.contentView {
            contentView.removeFromSuperview()
        }
    }

    private func didSetContentView() {
        if let contentView = self.contentView {
            self.tableView.hidden = true
            self.view.addSubview(contentView)
        }
        else {
            self.tableView.hidden = false
        }

        resize()
    }

    public func resize() {
        self.view.frame.size = self.desiredSize
        if let superview = self.view.superview {
            self.view.center = superview.center
        }
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
        if autoDismiss {
            dismiss()
        }

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
        if let action = actions.safeValue(indexPath.row) {
            let presenter = AlertCellPresenter(action: action, textAlignment: textAlignment)
            presenter.configureCell(cell, type: self.type)
        }
        return cell
    }
}
