//
//  StreamContainerViewController.swift
//  Ello
//
//  Created by Sean on 1/17/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit

protocol PostTappedDelegate : NSObjectProtocol {
    func postTapped(post : Post, initialItems: [StreamCellItem])
}

class StreamContainerViewController: StreamableViewController {

    enum Notifications : String {
        case StreamDetailTapped = "StreamDetailTappedNotification"
    }

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var navigationBar: ElloNavigationBar!
    @IBOutlet weak var navigationBarTopConstraint: NSLayoutConstraint!

    var streamsSegmentedControl: UISegmentedControl!
    var streamControllerViews:[UIView] = []
    var scrollLogic: ElloScrollLogic!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupStreamsSegmentedControl()
        setupChildViewControllers()
        navigationItem.titleView = streamsSegmentedControl
        navigationBar.items = [navigationItem]

        let tabBar = findTabBar(self.tabBarController!.view)
        scrollLogic = ElloScrollLogic(
            onShow: self.showNavBars,
            onHide: self.hideNavBars
        )
    }

    private func findTabBar(view: UIView) -> UITabBar? {
        if view.isKindOfClass(UITabBar.self) {
            return view as? UITabBar
        }

        var foundTabBar : UITabBar? = nil
        for subview : UIView in view.subviews as [UIView] {
            if foundTabBar == nil {
                foundTabBar = findTabBar(subview)
            }
        }
        return foundTabBar
    }

    func showNavBars() {
        navigationBarTopConstraint.constant = 0
        scrollView.setNeedsUpdateConstraints()
        if let tabBarController = self.tabBarController {
            tabBarController.tabBarHidden = false
        }
        self.view.layoutIfNeeded()
    }

    func hideNavBars() {
        navigationBarTopConstraint.constant = navigationBar.frame.height + 1
        scrollView.setNeedsUpdateConstraints()
        if let tabBarController = self.tabBarController {
            tabBarController.tabBarHidden = true
        }
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
            vc.streamScrollDelegate = self

            vc.willMoveToParentViewController(self)

            let x:CGFloat = CGFloat(index) * width
            let frame = CGRect(x: x, y: 0, width: width, height: height)
            vc.view.frame = frame
            scrollView.addSubview(vc.view)
            streamControllerViews.append(vc.view)

            self.addChildViewController(vc)
            vc.didMoveToParentViewController(self)

            setupControllerData(kind, controller: vc)
        }
    }

    private func setupControllerData(streamKind: StreamKind, controller: StreamViewController) {
        let streamService = StreamService()
        streamService.loadStream(streamKind.endpoint,
            success: { jsonables in
                var posts:[Post] = []
                for activity in jsonables {
                    if let post = (activity as Activity).subject as? Post {
                        posts.append(post)
                    }
                }

                let parser = StreamCellItemParser()
                controller.addUnsizedCellItems(parser.postCellItems(posts, streamKind: streamKind))
                controller.doneLoading()
            }, failure: { (error, statusCode) in
                println("failed to load \(streamKind.name) stream (reason: \(error))")
                controller.doneLoading()
            }
        )
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

    @IBAction func streamSegmentTapped(sender: UISegmentedControl) {
        let width:CGFloat = view.bounds.size.width
        let height:CGFloat = view.bounds.size.height
        let x:CGFloat = CGFloat(sender.selectedSegmentIndex) * width
        let rect = CGRect(x: x, y: 0, width: width, height: height)
        scrollView.scrollRectToVisible(rect, animated: true)
    }

}


// MARK: StreamContainerViewController: StreamScrollDelegate
extension StreamContainerViewController : StreamScrollDelegate {

    func streamViewDidScroll(scrollView : UIScrollView) {
        scrollLogic.scrollViewDidScroll(scrollView)
    }

    func streamViewWillBeginDragging(scrollView: UIScrollView) {
        scrollLogic.scrollViewWillBeginDragging(scrollView)
    }

    func streamViewDidEndDragging(scrollView: UIScrollView, willDecelerate: Bool) {
        scrollLogic.scrollViewDidEndDragging(scrollView, willDecelerate: willDecelerate)
    }

}