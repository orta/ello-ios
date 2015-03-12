//
//  Stubs.swift
//  Ello
//
//  Created by Ryan Boyajian on 3/6/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

func stub<T: Stubbable>(values: [String: AnyObject]) -> T {
    return T.stub(values)
}

protocol Stubbable: NSObjectProtocol {
    class func stub(values: [String: AnyObject]) -> Self
}

extension User: Stubbable {
    class func stub(values: [String: AnyObject]) -> User {

        let relationship = (values["relationshipPriority"] as? String).map {
            Relationship(stringValue: $0)
        } ?? Relationship.None

        return User(
            avatarURL: values["avatarURL"] as? NSURL,
            coverImageURL: values["coverImageURL"] as? NSURL,
            experimentalFeatures: (values["experimentalFeatures"] as? Bool) ?? false,
            followersCount: (values["followersCount"] as? Int) ?? 0,
            followingCount: (values["followingCount"] as? Int) ?? 0,
            href: (values["href"] as? String) ?? "href",
            name: (values["name"] as? String) ?? "name",
            posts: (values["posts"] as? [Post]) ?? [],
            postsCount: (values["postsCount"] as? Int) ?? 0,
            relationshipPriority: relationship,
            userId: (values["userId"] as? String) ?? "1",
            username: (values["username"] as? String) ?? "username",
            identifiableBy: .None,
            formattedShortBio: (values["formattedShortBio"] as? String) ?? "formattedShortBio"
        )
    }
}
