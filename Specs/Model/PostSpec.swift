//
//  PostSpec.swift
//  Ello
//
//  Created by Sean Dougherty on 11/21/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Quick
import Nimble

class PostSpec: QuickSpec {
    override func spec() {

        it("converts from JSON") {
            let body = "body of the post"

            let data = "{\"body\": \"\(body)\"}".dataUsingEncoding(NSUTF8StringEncoding)!
            let post = Post.fromJSON(data) as Post

            expect(post.body) == body
        }
        
    }
}
