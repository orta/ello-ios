//
//  ContentFlaggerSpec.swift
//  Ello
//
//  Created by Sean on 2/25/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Quick
import Nimble
import Moya


class ContentFlaggerSpec: QuickSpec {

    override func spec() {

        var subject: ContentFlagger!
        var post: Post!
        beforeEach({
            var presentingController = UIViewController()
            let keyWindow = UIWindow(frame: UIScreen.mainScreen().bounds)
            keyWindow.makeKeyAndVisible()
            keyWindow.rootViewController = presentingController
            presentingController.loadView()
            presentingController.viewDidLoad()
//            post = Post(assets: nil, author: nil, collapsed: <#Bool#>, commentsCount: <#Int?#>, content: <#[Regionable]?#>, createdAt: <#NSDate#>, href: <#String#>, postId: <#String#>, repostsCount: <#Int?#>, summary: <#[Regionable]?#>, token: <#String#>, viewsCount: <#Int?#>)

//            subject = ContentFlagger(presentingController: presentingController, post: <#Post#>)
        })


    }

}
