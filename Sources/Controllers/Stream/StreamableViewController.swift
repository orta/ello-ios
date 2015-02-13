//
//  StreamableViewController.swift
//  Ello
//
//  Created by Colin Gray on 2/5/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit

class StreamableViewController : BaseElloViewController, PostTappedDelegate {

    @IBAction func backTapped(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }

    func postTapped(post: Post, initialItems: [StreamCellItem]) {
        let vc = PostDetailViewController(post: post, items: initialItems)
        vc.currentUser = currentUser
        self.navigationController?.pushViewController(vc, animated: true)
    }

}