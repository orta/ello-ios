//
//  MappingType.swift
//  Ello
//
//  Created by Sean on 1/12/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//


public enum MappingType {
    // these keys define the place in the JSON response where the ElloProvider
    // should look for the response data.
    case CommentsType
    case PostsType
    case ActivitiesType
    case UsersType
    case ProfileType
    case ErrorType
    case ErrorsType
    case AssetsType
    case RelationshipsType
    case AmazonCredentialsType
    case NoContentType
    case AvailabilityType

    static func fromRawValue(value: String) -> MappingType? {
        switch value {
        case "comments":
            return .CommentsType
        case "posts":
            return .PostsType
        case "activities":
            return .ActivitiesType
        case "users":
            return .UsersType
        case "error":
            return .ErrorType
        case "errors":
            return .ErrorsType
        case "assets":
            return .AssetsType
        case "relationships":
            return .RelationshipsType
        case "credentials":
            return .AmazonCredentialsType
        case "204":
            return .NoContentType
        case "availability":
            return .AvailabilityType
        default:
            return nil
        }
    }

    var node: String {
        switch self {
        case CommentsType:
            return "comments"
        case PostsType:
            return "posts"
        case ActivitiesType:
            return "activities"
        case UsersType, ProfileType: // this is why MappingType can't be of type String
            return "users"
        case ErrorType:
            return "error"
        case ErrorsType:
            return "errors"
        case AssetsType:
            return "assets"
        case RelationshipsType:
            return "relationships"
        case AmazonCredentialsType:
            return "credentials"
        case NoContentType:
            return "204"
        case AvailabilityType:
            return "availability"
        }
    }

    var fromJSON: FromJSONClosure {
        switch self {
        case CommentsType:
            return Comment.fromJSON
        case PostsType:
            return Post.fromJSON
        case ActivitiesType:
            return Activity.fromJSON
        case UsersType:
            return User.fromJSON
        case ProfileType:
            return Profile.fromJSON
        case ErrorType:
            return ElloNetworkError.fromJSON
        case ErrorsType:
            return ElloNetworkError.fromJSON
        case AssetsType:
            return Asset.fromJSON
        case AmazonCredentialsType:
            return AmazonCredentials.fromJSON
        case AvailabilityType:
            return Availability.fromJSON
        default:
            return UnknownJSONAble.fromJSON
        }
    }

    var isOrdered: Bool {
        switch self {
        case AssetsType: return false
        default: return true
        }
    }

}

public class UnknownJSONAble : JSONAble {
     override class public func fromJSON(data: [String : AnyObject]) -> JSONAble {
        return UnknownJSONAble()
    }
}
