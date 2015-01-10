//
//  CommentSpec.swift
//  Ello
//
//  Created by Sean on 1/10/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Quick
import Nimble

class CommentSpec: QuickSpec {
    override func spec() {
        
        func linkedUser() -> [String:AnyObject] {
            let avatar = "http://ello.dev/uploads/user/avatar/42/avatar.png"
            let userId = "43"
            let name = "Secret Spy"
            let username = "archer"
            
            return ["avatar_url" : avatar, "id" : userId, "name" : name, "username" : username]
        }
        

        it("converts from JSON") {
            
            let commentId = "666"
            let createdAtString = "2013-11-30T05:57:53.936Z"
            let summary = ["one", "eleven"]
            let links = ["author":["type":"users", "href":"/api/edge/users/43", "id":"43"]]
            
            let authorAvatar = "http://ello.dev/uploads/user/avatar/42/avatar.png"
            let authorAvatarURL = NSURL(string: authorAvatar)
            let authorId = "43"
            let authorName = "Secret Spy"
            let authorUsername = "archer"
            
            let userData:[String: AnyObject] = ["avatar_url" : authorAvatar, "id" : authorId, "name" : authorName, "username" : authorUsername]
            
            let linkedObjects = ["users":[userData as AnyObject]]

            let data:[String:AnyObject] = ["id" : commentId, "created_at" : createdAtString, "summary" : summary, "links" : links]
            
            let comment = Comment.fromJSON(data, linked: linkedObjects) as Comment
            
            var createdAt:NSDate = createdAtString.toNSDate()!
            
            expect(comment.createdAt) == createdAt
            expect(comment.summary) == summary
            expect(comment.commentId) == commentId.toInt()
            
            expect(comment.author).to(beAnInstanceOf(User.self))
            expect(comment.author!.name) == authorName
            expect(comment.author!.userId) == authorId.toInt()
            expect(comment.author!.username) == authorUsername
            expect(comment.author!.avatarURL) == authorAvatarURL
        }
    }
}
