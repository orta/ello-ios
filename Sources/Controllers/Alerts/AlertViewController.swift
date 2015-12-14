//
//  AlertViewController.swift
//  Ello
//
//  Created by Gordon Fontenot on 4/1/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Crashlytics

private let DesiredWidth: CGFloat = 300
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

    var keyboardWillShowObserver: NotificationObserver?
    var keyboardWillHideObserver: NotificationObserver?

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
            let contentHeight = tableView.contentSize.height + totalVerticalPadding
            let height = min(contentHeight, MaxHeight)
            return CGSize(width: DesiredWidth, height: height)
        }
    }

    public var dismissable = true
    public var autoDismiss = true

    public private(set) var actions: [AlertAction] = []
    private var inputs: [String] = []
    var actionInputs: [String] {
        var retVals: [String] = []
        for (index, action) in actions.enumerate() {
            if action.isInput {
                retVals.append(inputs[index])
            }
        }
        return retVals
    }

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
        set(text) {
            headerView.label.setLabelText(text, color: UIColor.blackColor())
            tableView.reloadData()
        }
    }

    private let headerView: AlertHeaderView = {
        return AlertHeaderView.loadFromNib()
    }()

    private var totalHorizontalPadding: CGFloat {
        return leftPadding.constant + rightPadding.constant
    }

    private var totalVerticalPadding: CGFloat {
        return 2 * topPadding.constant
    }

    public init(message: String? = nil, textAlignment: NSTextAlignment = .Center, type: AlertType = .Normal) {
        self.textAlignment = textAlignment
        super.init(nibName: "AlertViewController", bundle: NSBundle(forClass: AlertViewController.self))

        modalPresentationStyle = .Custom
        transitioningDelegate = self
        headerView.label.setLabelText(message ?? "", color: type.headerTextColor)

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

        keyboardWillShowObserver = NotificationObserver(notification: Keyboard.Notifications.KeyboardWillShow, block: self.keyboardUpdateFrame)
        keyboardWillHideObserver = NotificationObserver(notification: Keyboard.Notifications.KeyboardWillHide, block: self.keyboardUpdateFrame)

        if type == .Clear {
            leftPadding.constant = 5
            rightPadding.constant = 5
        }
    }

    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        tableView.scrollEnabled = (view.frame.height == MaxHeight)
    }

    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        keyboardWillShowObserver?.removeObserver()
        keyboardWillShowObserver = nil
        keyboardWillHideObserver?.removeObserver()
        keyboardWillHideObserver = nil
    }

    public func dismiss(animated: Bool = true, completion: ElloEmptyCompletion? = .None) {
        dismissViewControllerAnimated(animated, completion: completion)
    }

    func keyboardUpdateFrame(keyboard: Keyboard) {
        let availHeight = UIWindow.mainWindow.frame.height - (Keyboard.shared().active ? Keyboard.shared().endFrame.height : 0)
        let top = max(15, (availHeight - view.frame.height) / 2)
        animate(duration: Keyboard.shared().duration) {
            self.view.frame.origin.y = top

            let bottomInset = Keyboard.shared().keyboardBottomInset(inView: self.tableView)
            self.tableView.contentInset.bottom = bottomInset
            self.tableView.scrollIndicatorInsets.bottom = bottomInset
            self.tableView.scrollEnabled = (bottomInset > 0 || self.view.frame.height == MaxHeight)
        }
    }
}

public extension AlertViewController {
    func addAction(action: AlertAction) {
        actions.append(action)
        inputs.append("")

        tableView.reloadData()
    }

    func resetActions() {
        actions = []
        inputs = []

        tableView.reloadData()
    }
}

extension AlertViewController {
    private func willSetContentView() {
        if let contentView = contentView {
            contentView.removeFromSuperview()
        }
    }

    private func didSetContentView() {
        if let contentView = contentView {
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

// MARK: UIViewControllerTransitioningDelegate
extension AlertViewController: UIViewControllerTransitioningDelegate {
    public func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        if presented != self { return .None }

        return AlertPresentationController(presentedViewController: presented, presentingViewController: presenting, backgroundColor: self.modalBackgroundColor)
    }
}

// MARK: UITableViewDelegate
extension AlertViewController: UITableViewDelegate {
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if autoDismiss {
            dismiss()
        }

        if let action = actions.safeValue(indexPath.row)
            where !action.isInput
        {
            action.handler?(action)
        }
    }

    public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if message.characters.count == 0 {
            return nil
        }
        return headerView
    }

    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if message.characters.count == 0 {
            return 0
        }
        let size = CGSize(width: DesiredWidth - totalHorizontalPadding, height: .max)
        let height = headerView.label.sizeThatFits(size).height
        return height
    }
}

// MARK: UITableViewDataSource
extension AlertViewController: UITableViewDataSource {
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actions.count
    }

    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(AlertCell.reuseIdentifier(), forIndexPath: indexPath) as! AlertCell

        if let action = actions.safeValue(indexPath.row), input = inputs.safeValue(indexPath.row) {
            action.configure(cell: cell, type: type, action: action, textAlignment: textAlignment)

            cell.input.text = input
            cell.onInputChanged = { text in
                self.inputs[indexPath.row] = text
            }
        }

        cell.delegate = self
        cell.backgroundColor = type.cellColor
        return cell
    }
}

extension AlertViewController: AlertCellDelegate {
    public func tappedOkButton() {
        dismiss()

        if let action = actions.find({ action in
            switch action.style {
            case .OKCancel: return true
            default: return false
            }
        }) {
            action.handler?(action)
        }
    }

    public func tappedCancelButton() {
        dismiss()
    }
}
