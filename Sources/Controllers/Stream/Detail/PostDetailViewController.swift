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
    var unsizedCellItems : [StreamCellItem]

    convenience init(post : Post, items: [StreamCellItem]) {
        self.init(post: post, items: items, unsized: [])
    }

    convenience init(post : Post, unsized: [StreamCellItem]) {
        self.init(post: post, items: [], unsized: unsized)
    }

    required init(post : Post, items: [StreamCellItem], unsized: [StreamCellItem]) {
        self.post = post
        self.detailCellItems = items
        self.unsizedCellItems = unsized

        super.init(nibName: nil, bundle: nil)

        self.title = post.author?.atName ?? "Profile"
        self.view.backgroundColor = UIColor.whiteColor()
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

        controller.willMoveToParentViewController(self)
        self.view.addSubview(controller.view)
        self.addChildViewController(controller)
        controller.didMoveToParentViewController(self)

        controller.addStreamCellItems(self.detailCellItems)
        controller.addUnsizedCellItems(self.unsizedCellItems)

        let streamService = StreamService()
        streamService.loadMoreCommentsForPost(post.postId,
            success: { jsonables in
                var parser = StreamCellItemParser()
                controller.addUnsizedCellItems(parser.commentCellItems(jsonables as [Comment]))
                controller.doneLoading()
            },
            failure: { (error, statusCode) -> () in
                println("failed to load comments (reason: \(error))")
                controller.doneLoading()
            }
        )
    }

    override func postTapped(post: Post, initialItems: [StreamCellItem]) {
        if post.postId != self.post.postId {
            super.postTapped(post, initialItems: initialItems)
        }
    }
}
