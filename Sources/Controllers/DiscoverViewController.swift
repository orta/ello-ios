//
//  DiscoverViewController.swift
//  Ello
//
//  Created by Sean Dougherty on 11/20/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit

class DiscoverViewController: BaseElloViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let target: ElloAPI = .Posts
        ElloAPIProvider.request(.Posts, completion: { (data, statusCode, response, error) in
            if let data = data {
                let post = Post.fromJSON(data) as Post
                println("Post body = \(post.body)")
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    class func instantiateFromStoryboard(storyboard: UIStoryboard = UIStoryboard.iPhone()) -> DiscoverViewController {
        return storyboard.controllerWithID(.Discover) as DiscoverViewController
    }

}

