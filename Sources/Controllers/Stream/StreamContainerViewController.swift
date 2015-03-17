//
//  StreamContainerViewController.swift
//  Ello
//
//  Created by Sean on 1/17/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit


class StreamContainerViewController: StreamableViewController {

    enum Notifications : String {
        case StreamDetailTapped = "StreamDetailTappedNotification"
    }

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var navigationBar: ElloNavigationBar!
    @IBOutlet weak var navigationBarTopConstraint: NSLayoutConstraint!

    var streamsSegmentedControl: UISegmentedControl!
    var streamControllerViews:[UIView] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupStreamsSegmentedControl()
        setupChildViewControllers()
        navigationItem.titleView = streamsSegmentedControl
        navigationBar.items = [navigationItem]

        scrollLogic.prevOffset = (childViewControllers[0] as StreamViewController).collectionView.contentOffset
    }

    override func showNavBars(scrollToBottom : Bool) {
        super.showNavBars(scrollToBottom)
        navigationBarTopConstraint.constant = 0
        self.view.layoutIfNeeded()

        if scrollToBottom {
            for controller in childViewControllers as [StreamViewController] {
                if let scrollView = controller.collectionView {
                    let contentOffsetY : CGFloat = scrollView.contentSize.height - scrollView.frame.size.height
                    if contentOffsetY > 0 {
                        scrollView.scrollEnabled = false
                        scrollView.setContentOffset(CGPoint(x: 0, y: contentOffsetY), animated: true)
                        scrollView.scrollEnabled = true
                    }
                }
            }
        }
    }

    override func hideNavBars() {
        super.hideNavBars()
        navigationBarTopConstraint.constant = navigationBar.frame.height + 1
        self.view.layoutIfNeeded()
    }

    class func instantiateFromStoryboard() -> StreamContainerViewController {
        let navController = UIStoryboard.storyboardWithId(.StreamContainer) as UINavigationController
        let streamsController = navController.topViewController
        return streamsController as StreamContainerViewController
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let width:CGFloat = scrollView.frame.size.width
        let height:CGFloat = scrollView.frame.size.height
        var x : CGFloat = 0

        for view in streamControllerViews {
            view.frame = CGRect(x: x, y: 0, width: width, height: height)
            x += width
        }

        scrollView.contentSize = CGSize(width: width * CGFloat(countElements(StreamKind.streamValues)), height: height)
    }

    private func setupChildViewControllers() {
        scrollView.scrollEnabled = false
        let width:CGFloat = scrollView.frame.size.width
        let height:CGFloat = scrollView.frame.size.height

        for (index, kind) in enumerate(StreamKind.streamValues) {
            let vc = StreamViewController.instantiateFromStoryboard()
            vc.streamKind = kind
            vc.postTappedDelegate = self
            vc.userTappedDelegate = self
            vc.streamScrollDelegate = self

            vc.willMoveToParentViewController(self)

            let x:CGFloat = CGFloat(index) * width
            let frame = CGRect(x: x, y: 0, width: width, height: height)
            vc.view.frame = frame
            scrollView.addSubview(vc.view)
            streamControllerViews.append(vc.view)

            self.addChildViewController(vc)
            vc.didMoveToParentViewController(self)

            vc.loadInitialPage()
        }
    }

    private func setupNavigationBar() {
        navigationBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 30)
    }

    private func setupStreamsSegmentedControl() {
        let control = UISegmentedControl(items: StreamKind.streamValues.map{ $0.name })
        control.addTarget(self, action: "streamSegmentTapped:", forControlEvents: .ValueChanged)
        var rect = control.bounds
        rect.size = CGSize(width: rect.size.width, height: 19.0)
        control.bounds = rect
        control.layer.borderColor = UIColor.blackColor().CGColor
        control.layer.borderWidth = 1.0
        control.layer.cornerRadius = 0.0
        control.selectedSegmentIndex = 0
        streamsSegmentedControl = control
    }

    // MARK: - IBActions

    @IBAction func hamburgerButtonTapped(sender: UIBarButtonItem) {
        let index = streamsSegmentedControl.selectedSegmentIndex
        let relationship = StreamKind.streamValues[index].relationship
        let drawer = DrawerViewController(relationship: relationship)
        self.navigationController?.pushViewController(drawer, animated: true)
    }

    @IBAction func streamSegmentTapped(sender: UISegmentedControl) {
        let width:CGFloat = view.bounds.size.width
        let height:CGFloat = view.bounds.size.height
        let x:CGFloat = CGFloat(sender.selectedSegmentIndex) * width
        let rect = CGRect(x: x, y: 0, width: width, height: height)
        scrollView.scrollRectToVisible(rect, animated: true)
    }

}
