//
//  AlertViewController.swift
//  Ello
//
//  Created by Gordon Fontenot on 4/1/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

private let DesiredWidth: CGFloat = 300
private let HelpButtonSpace: CGFloat = 49
private let MaxHeight = UIScreen.mainScreen().applicationFrame.height - 20

public enum AlertType {
    case Normal
    case Danger
    case Clear

    var backgroundColor: UIColor {
        switch self {
        case .Danger: return .redColor()
        case .Clear: return .clearColor()
        default: return .whiteColor()
        }
    }

    var headerTextColor: UIColor {
        switch self {
        case .Clear: return .whiteColor()
        default: return .blackColor()
        }
    }

    var cellColor: UIColor {
        switch self {
        case .Clear: return .clearColor()
        default: return .whiteColor()
        }
    }
}

public class AlertViewController: UIViewController {
    @IBOutlet public weak var tableView: UITableView!
    @IBOutlet public weak var topPadding: NSLayoutConstraint!
    @IBOutlet public weak var leftPadding: NSLayoutConstraint!
    @IBOutlet public weak var rightPadding: NSLayoutConstraint!

    // assign a contentView to show a message or spinner.  The contentView frame
    // size must be set.
    public var contentView: UIView? {
        willSet { willSetContentView() }
        didSet { didSetContentView() }
    }

    public var modalBackgroundColor: UIColor = .modalBackground()

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

    public var dismissable = true
    public var autoDismiss = true

    public private(set) var actions: [AlertAction] = []
    private let textAlignment: NSTextAlignment
    public var type: AlertType = .Normal {
        didSet {
            let backgroundColor = type.backgroundColor
            view.backgroundColor = backgroundColor
            tableView.backgroundColor = backgroundColor
            headerView.backgroundColor = backgroundColor
            tableView.reloadData()
        }
    }

    public var message: String {
        get { return headerView.label.text ?? "" }
        set(text) { headerView.label.setLabelText(text, color: UIColor.blackColor())}
    }

    public var helpText: String?

    private let headerView: AlertHeaderView = {
        return AlertHeaderView.loadFromNib()
    }()

    private var totalHorizontalPadding: CGFloat {
        return leftPadding.constant + rightPadding.constant
    }

    private var totalVerticalPadding: CGFloat {
        return 2 * topPadding.constant
    }

    public init(message: String? = nil, textAlignment: NSTextAlignment = .Center, type: AlertType = .Normal, helpText: String? = nil) {
        self.helpText = helpText
        self.textAlignment = textAlignment
        super.init(nibName: "AlertViewController", bundle: NSBundle(forClass: AlertViewController.self))

        modalPresentationStyle = .Custom
        transitioningDelegate = self
        headerView.label.setLabelText(message ?? "", color: type.headerTextColor)
        headerView.helpButtonVisible = helpText != nil
        headerView.delegate = self

        view.backgroundColor = type.backgroundColor
        tableView.backgroundColor = type.backgroundColor
        headerView.backgroundColor = type.backgroundColor
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

    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if type == .Clear {
            leftPadding.constant = 5
            rightPadding.constant = 5
        }
    }

    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        tableView.scrollEnabled = (CGRectGetHeight(self.view.frame) == MaxHeight)
    }

    public func dismiss(animated: Bool = true, completion: ElloEmptyCompletion? = .None) {
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

// MARK: AlertHeaderDelegate
extension AlertViewController: AlertHeaderDelegate {
    public func helpTapped() {
        let alertController = AlertViewController(message: helpText, textAlignment: .Center, type: .Normal)
        alertController.modalBackgroundColor = .clearColor()
        let gotItAction = AlertAction(
            title: NSLocalizedString("Got it", comment: "Ok"),
            icon: nil,
            style: .Dark,
            handler: nil)
        alertController.addAction(gotItAction)
        self.presentViewController(alertController, animated: true, completion: .None)
    }
}

// MARK: UIViewControllerTransitioningDelegate
extension AlertViewController: UIViewControllerTransitioningDelegate {
    public func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController!, sourceViewController source: UIViewController) -> UIPresentationController? {
        if presented != self { return .None }

        let controller = AlertPresentationController(presentedViewController: presented, presentingViewController: presenting, backgroundColor: self.modalBackgroundColor)
        return controller
    }
}

// MARK: UITableViewDelegate
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
        if count(message) == 0 {
            return nil
        }
        return headerView
    }

    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if count(message) == 0 {
            return 0
        }
        let space = helpText == nil ? 0 : HelpButtonSpace
        let size = CGSize(width: DesiredWidth - totalHorizontalPadding - space, height: .max)
        let height = headerView.label.sizeThatFits(size).height
        return height
    }
}

// MARK: UITableViewDataSource
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
        cell.backgroundColor = type.cellColor
        return cell
    }
}
