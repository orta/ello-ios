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

enum StreamKind {
    case Friend
    case Noise
    case PostDetail(post: Post)
    case Profile(user: User)

    var name:String {
        switch self {
        case .Friend: return "Friends"
        case .Noise: return "Noise"
        case .PostDetail: return "Post Detail"
        case .Profile(let user): return "@\((user as User).username)"
        }
    }

    var columnCount:Int {
        switch self {
        case .Noise: return 2
        default: return 1
        }
    }

    var endpoint:ElloAPI {
        switch self {
        case .Friend: return .FriendStream
        case .Noise: return .NoiseStream
        case .PostDetail: return .NoiseStream // never use
        case .Profile(let user): return .UserStream(userId: (user as User).userId)
        }
    }

    var isGridLayout:Bool {
        return self.columnCount > 1
    }

    var isDetail:Bool {
        switch self {
        case .PostDetail: return true
        default: return false
        }
    }

    static let streamValues = [Friend, Noise]
}

class StreamContainerViewController: StreamableViewController {

    enum Notifications : String {
        case StreamDetailTapped = "StreamDetailTappedNotification"
    }

    @IBOutlet weak var scrollView: UIScrollView!

    var streamsSegmentedControl: UISegmentedControl!
    var streamControllerViews:[UIView] = []
    var streamControllers:[BaseElloViewController] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupStreamsSegmentedControl()
        setupChildViewControllerContainers()
        setupChildViewControllers()
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

        for (index, _) in enumerate(StreamKind.streamValues) {
            let x:CGFloat = CGFloat(index) * width
            let frame = CGRect(x: x, y: 0, width: width, height: height)
            let view = UIView(frame: frame)
            scrollView.addSubview(view)
            streamControllerViews.append(view)
        }
        scrollView.contentSize = CGSize(width: width * CGFloat(countElements(StreamKind.streamValues)), height: height)
        scrollView.scrollEnabled = false
    }

    private func setupChildViewControllers() {
        for (index, kind) in enumerate(StreamKind.streamValues) {
//            if index == 0 {
                let vc = StreamViewController.instantiateFromStoryboard()
                vc.streamKind = kind
                vc.postTappedDelegate = self
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

                setupControllerData(kind, controller: vc)
//            }
        }
    }

    private func setupControllerData(streamKind: StreamKind, controller: StreamViewController) {
        let streamService = StreamService()
        streamService.loadStream(streamKind.endpoint,
            success: { (streamables) in
                controller.addStreamables(streamables)
                controller.doneLoading()
            }, failure: { (error, statusCode) in
                println("failed to load noise stream (reason: \(error))")
            }
        )
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
