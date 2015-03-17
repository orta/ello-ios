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
    case PostsType =             "posts"
    case ActivitiesType =        "activities"
    case UsersType =             "users"
    case ErrorType =             "error"
    case ErrorsType =            "errors"
    case AssetsType =            "assets"
    case RelationshipsType =     "relationships"
    case AmazonCredentialsType = "credentials"
    case NoContentType =         "204"

    var fromJSON: FromJSONClosure {
        switch self {
        case CommentsType:                  return Comment.fromJSON
        case PostsType:                     return Post.fromJSON
        case ActivitiesType:                return Activity.fromJSON
        case UsersType:                     return User.fromJSON
        case ErrorType:                     return ElloNetworkError.fromJSON
        case ErrorsType:                    return ElloNetworkError.fromJSON
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
