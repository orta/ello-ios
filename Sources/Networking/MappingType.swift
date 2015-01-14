//
//  MappingType.swift
//  Ello
//
//  Created by Sean on 1/12/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

class MappingType {

    class var types: [Prop : JSONAble.Type] {
        return [
            Prop.Activities : Activity.self,
            Prop.Activity : Activity.self,
            Prop.Posts : Post.self,
            Prop.Post : Post.self,
            Prop.User : User.self,
            Prop.Users : User.self,
            Prop.Comments : Comment.self,
            Prop.Comment : Comment.self,
            Prop.Errors : ElloNetworkError.self,
            Prop.Error : ElloNetworkError.self
        ]
    }
    
    enum Prop: String {
        case Comments = "comments"
        case Comment = "comment"
        case Posts = "posts"
        case Post = "post"
        case Activities = "activities"
        case Activity = "activity"
        case Users = "users"
        case User = "user"
        case Errors = "errors"
        case Error = "error"
    }
    
}
