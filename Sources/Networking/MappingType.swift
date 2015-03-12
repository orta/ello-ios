//
//  MappingType.swift
//  Ello
//
//  Created by Sean on 1/12/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//


enum MappingType: String {
    // these keys define the place in the JSON response where the ElloProvider
    // should look for the response data.
    case CommentsType =          "comments"
    case CommentType =           "comment"
    case PostsType =             "posts"
    case PostType =              "post"
    case ActivitiesType =        "activities"
    case ActivityType =          "activity"
    case UsersType =             "users"
    case UserType =              "user"
    case ErrorsType =            "errors"
    case ErrorType =             "error"
    case AssetsType =            "assets"
    case RelationshipsType =     "relationships"
    case AmazonCredentialsType = "credentials"
    case NoContentType =         "204"

    var fromJSON: FromJSONClosure {
        switch self {
        case CommentsType, CommentType:     return Comment.fromJSON
        case PostsType, PostType:           return Post.fromJSON
        case ActivitiesType, ActivityType:  return Activity.fromJSON
        case UsersType, UserType:           return User.fromJSON
        case ErrorsType, ErrorType:         return ElloNetworkError.fromJSON
        case AssetsType:                    return Asset.fromJSON
        case AmazonCredentialsType:         return AmazonCredentials.fromJSON
        default:                            return UnknownJSONAble.fromJSON
        }
    }

    var isOrdered: Bool {
        switch self {
        case AssetsType: return false
        default: return true
        }
    }

}

class UnknownJSONAble : JSONAble {
     override class func fromJSON(data: [String : AnyObject]) -> JSONAble {
        return UnknownJSONAble()
    }
}
