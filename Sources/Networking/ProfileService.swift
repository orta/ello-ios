//
//  ProfileService.swift
//  Ello
//
//  Created by Sean on 2/15/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

import UIKit
import Moya
import SwiftyJSON

public typealias ProfileFollowingSuccessCompletion = (users: [User], responseConfig: ResponseConfig) -> ()

public struct ProfileService {

    public init(){}
    
    public func loadCurrentUser(success: UserSuccessCompletion, failure: ElloFailureCompletion?) {
        ElloProvider.elloRequest(ElloAPI.Profile,
            method: .GET,
            success: { (data, responseConfig) in
                if let user = data as? User {
                    success(user: user, responseConfig: responseConfig)
                }
                else {
                    ElloProvider.unCastableJSONAble(failure)
                }
            },
            failure: failure
        )
    }

    public func loadCurrentUserFollowing(forRelationship relationship: Relationship, success: ProfileFollowingSuccessCompletion, failure: ElloFailureCompletion?) {
        ElloProvider.elloRequest(ElloAPI.ProfileFollowing(priority: relationship.rawValue),
            method: .GET,
            success: { data, responseConfig in
                if let users = data as? [User] {
                    success(users: users, responseConfig: responseConfig)
                }
                else {
                    ElloProvider.unCastableJSONAble(failure)
                }
            },
            failure: failure
        )
    }

    public func updateUserProfile(content: [String: AnyObject], success: UserSuccessCompletion, failure: ElloFailureCompletion?) {
        ElloProvider.elloRequest(ElloAPI.ProfileUpdate(body: content),
            method: .PATCH,
            success: { data, responseConfig in
                if let user = data as? User {
                    success(user: user, responseConfig: responseConfig)
                } else {
                    ElloProvider.unCastableJSONAble(failure)
                }
            },
            failure: failure
        )
    }

    public func updateUserCoverImage(image: UIImage, success: UserSuccessCompletion, failure: ElloFailureCompletion) {
        S3UploadingService().upload(image, filename: "cover.jpeg", success: { url in
            self.updateUserProfile(["remote_cover_image_url": url], success: success, failure: failure)
        }, failure: failure)
    }

    public func updateUserAvatarImage(image: UIImage, success: UserSuccessCompletion, failure: ElloFailureCompletion) {
        S3UploadingService().upload(image, filename: "avatar.jpeg", success: { url in
            self.updateUserProfile(["remote_avatar_url": url], success: success, failure: failure)
        }, failure: failure)
    }
}
