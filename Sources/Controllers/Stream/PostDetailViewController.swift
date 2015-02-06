//
//  PostDetailViewController.swift
//  Ello
//
//  Created by Colin Gray on 2/5/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit

class PostDetailViewController: StreamableViewController {

    var post : Post
    var detailCellItems : [StreamCellItem]

    required init(post : Post, items: [StreamCellItem]) {
        self.post = post
        self.detailCellItems = items

        super.init(nibName: nil, bundle: nil)

        self.title = post.author?.at_name ?? "Profile"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let item = UIBarButtonItem.backChevronWithTarget(self, action: "backTapped:")
        self.navigationItem.leftBarButtonItem = item

        setupStreamController()
    }

    private func setupStreamController() {
        let controller = StreamViewController.instantiateFromStoryboard()
        controller.streamKind = .PostDetail(post: self.post)
        controller.postTappedDelegate = self

        controller.addStreamCellItems(self.detailCellItems)

        let streamService = StreamService()
        streamService.loadMoreCommentsForPost(post.postId,
            success: { (streamables) -> () in
                controller.addStreamables(streamables)
                controller.doneLoading()
            }) { (error, statusCode) -> () in
                println("failed to load comments")
        }

        controller.willMoveToParentViewController(self)
        self.view.addSubview(controller.view)
        self.addChildViewController(controller)
    }

}
