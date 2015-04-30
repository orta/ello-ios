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
public typealias AccountDeletionSuccessCompletion = () -> ()

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
        updateUserImage(image, key: "remote_cover_image_url", success: success, failure: failure)
    }

    public func updateUserAvatarImage(image: UIImage, success: UserSuccessCompletion, failure: ElloFailureCompletion) {
        updateUserImage(image, key: "remote_avatar_url", success: success, failure: failure)
    }

    public func updateUserDeviceToken(token: NSData) {
        ElloProvider.elloRequest(ElloAPI.PushSubscriptions(token: token),
            method: .POST,
            success: { _, _ in },
            failure: .None)
    }

    public func removeUserDeviceToken(token: NSData) {
        ElloProvider.elloRequest(ElloAPI.PushSubscriptions(token: token),
            method: .DELETE,
            success: { _, _ in },
            failure: .None)
    }

    private func updateUserImage(image: UIImage, key: String, success: UserSuccessCompletion, failure: ElloFailureCompletion) {
        S3UploadingService().upload(image, filename: "\(NSUUID().UUIDString).png", success: { url in
            if let urlString = url?.absoluteString {
                self.updateUserProfile([key: urlString], success: success, failure: failure)
            }
        }, failure: failure)
    }

    public func deleteAccount(success: AccountDeletionSuccessCompletion, failure: ElloFailureCompletion?) {
        ElloProvider.elloRequest(ElloAPI.ProfileDelete,
            method: .DELETE,
            success: { _, _ in success() },
            failure: failure)
    }
}
