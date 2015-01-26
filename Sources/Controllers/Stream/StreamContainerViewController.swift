//
//  StreamContainerViewController.swift
//  Ello
//
//  Created by Sean on 1/17/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit

class StreamContainerViewController: BaseElloViewController {

    enum Notifications : String {
        case StreamDetailTapped = "StreamDetailTappedNotification"
    }

    @IBOutlet weak var scrollView: UIScrollView!
    
    var streamsSegmentedControl: UISegmentedControl!
    var streamControllerViews:[UIView] = []
    var streamControllers:[BaseElloViewController] = []
    let segments = ["Friends", "Noise"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStreamsSegmentedControl()
        setupChildViewControllerContainers()
        setupChildViewControllers()
        setupNotificationObservers()
        navigationItem.titleView = streamsSegmentedControl
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    class func instantiateFromStoryboard(storyboard: UIStoryboard = UIStoryboard.iPhone()) -> StreamContainerViewController {
        let navController = storyboard.controllerWithID(.StreamContainer) as UINavigationController
        let streamsController = navController.topViewController
        return streamsController as StreamContainerViewController
    }    

    private func setupChildViewControllerContainers() {
        let width:CGFloat = self.view.bounds.size.width
        let height:CGFloat = self.view.bounds.size.height
        for (index, segment) in enumerate(segments) {
            let x:CGFloat = CGFloat(index) * width
            let frame = CGRect(x: x, y: 0, width: width, height: height)
            let view = UIView(frame: frame)
            scrollView.addSubview(view)
            streamControllerViews.append(view)
        }
        scrollView.contentSize = CGSize(width: width * CGFloat(countElements(segments)), height: height)
        scrollView.scrollEnabled = false
    }
    
    private func setupChildViewControllers() {
        for (index, segment) in enumerate(segments) {
            if index == 0 {
                let vc = StreamViewController.instantiateFromStoryboard()
                vc.willMoveToParentViewController(self)
                let childView = streamControllerViews[index]
                childView.addSubview(vc.view)
                self.addChildViewController(vc)

                vc.view.setTranslatesAutoresizingMaskIntoConstraints(false)
                let views = ["view":vc.view]
                let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[view]-49-|", options: NSLayoutFormatOptions.AlignAllLeft, metrics: nil, views: views)
                childView.addConstraints(verticalConstraints)

                let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[view]-0-|", options: NSLayoutFormatOptions.AlignAllLeft, metrics: nil, views: views)
                childView.addConstraints(horizontalConstraints)

                vc.didMoveToParentViewController(self)
                streamControllers.append(vc)
            }
        }
    }

    private func setupNotificationObservers() {
        let center = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: Selector("streamDetailTapped:"), name: StreamContainerViewController.Notifications.StreamDetailTapped.rawValue, object: nil)
    }
    
    private func setupStreamsSegmentedControl() {
        let control = UISegmentedControl(items: segments)
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
    
    // MARK: Keyboard Event Notifications
    
    func streamDetailTapped(notification: NSNotification) {
        if let vc = notification.object as? BaseElloViewController {
            let item = UIBarButtonItem.backChevronWithTarget(self, action: "backTapped:")
            vc.navigationItem.leftBarButtonItem = item
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    // MARK: - IBActions
    
    @IBAction func streamSegmentTapped(sender: UISegmentedControl) {
        let width:CGFloat = view.bounds.size.width
        let height:CGFloat = view.bounds.size.height
        let x:CGFloat = CGFloat(sender.selectedSegmentIndex) * width
        let rect = CGRect(x: x, y: 0, width: width, height: height)
        scrollView.scrollRectToVisible(rect, animated: true)
    }
    
    @IBAction func backTapped(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}
