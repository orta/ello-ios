//
//  Stubs.swift
//  Ello
//
//  Created by Ryan Boyajian on 3/6/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

func stub<T: Stubbable>(values: [String: AnyObject]?) -> T {
    return T.stub(values)
}

let stubbedTextRegion: TextRegion = stub(nil)

protocol Stubbable: NSObjectProtocol {
    class func stub(values: [String: AnyObject]?) -> Self
}

extension User: Stubbable {
    class func stub(values: [String: AnyObject]) -> User {

        let relationship = (values["relationshipPriority"] as? String).map {
            Relationship(stringValue: $0)
        } ?? Relationship.None

        return User(
            avatarURL: (values?["avatarURL"] as? NSURL) ?? nil,
            coverImageURL: (values?["coverImageURL"] as? NSURL) ?? nil,
            experimentalFeatures: (values?["experimentalFeatures"] as? Bool) ?? false,
            followersCount: (values?["followersCount"] as? Int) ?? 0,
            followingCount: (values?["followingCount"] as? Int) ?? 0,
            href: (values?["href"] as? String) ?? "href",
            name: (values?["name"] as? String) ?? "name",
            posts: (values?["posts"] as? [Post]) ?? [],
            postsCount: (values?["postsCount"] as? Int) ?? 0,
            relationshipPriority: relationship,
            userId: (values?["userId"] as? String) ?? "1",
            username: (values?["username"] as? String) ?? "username",
            formattedShortBio: (values?["formattedShortBio"] as? String) ?? "formattedShortBio",
            isCurrentUser: (values?["isCurrentUser"] as? Bool) ?? false
        )
    }
}

extension Post: Stubbable {
    class func stub(values: [String: AnyObject]?) -> Post {
        let author = (values?["author"] as? User)
        let assets = (values?["assets"] as? [String : Asset])
        let content = (values?["content"] as? [Regionable]) ?? [stubbedTextRegion]
        let summary = (values?["summary"] as? [Regionable]) ?? [stubbedTextRegion]

        var post = Post(
            assets: assets,
            author: author,
            collapsed: (values?["collapsed"] as? Bool) ?? false,
            commentsCount: values?["commentsCount"] as? Int,
            content: content,
            createdAt: (values?["createdAt"] as? NSDate) ?? NSDate(),
            href: (values?["href"] as? String) ?? "sample-href",
            postId: (values?["postId"] as? String) ?? "666",
            repostsCount: (values?["repostsCount"] as? Int),
            summary: summary,
            token: (values?["token"] as? String) ?? "sample-token",
            viewsCount: values?["viewsCount"] as? Int
        )

        return post
    }

    class func stubWithRegions(values: [String: AnyObject]?, summary: [Regionable] = [], content: [Regionable] = []) -> Post {
        var post: Post = stub(values)
        post.summary = summary
        post.content = content
        return post
    }

}

extension Comment: Stubbable {
    class func stub(values: [String: AnyObject]?) -> Comment {
        let author = (values?["author"] as? User)
        let content = (values?["content"] as? [Regionable]) ?? [stubbedTextRegion]
        let summary = (values?["summary"] as? [Regionable]) ?? [stubbedTextRegion]
        let parentPost = (values?["parentPost"] as? Post)

        return Comment(
            author: author,
            commentId: (values?["commentId"] as? String) ?? "888",
            content: content,
            createdAt: (values?["createdAt"] as? NSDate) ?? NSDate(),
            parentPost: parentPost,
            summary: summary
        )
    }
}

extension TextRegion: Stubbable {
    class func stub(values: [String: AnyObject]?) -> TextRegion {
        return TextRegion(
            content: (values?["content"] as? String) ?? "Lorem Ipsum"
        )
    }
}

extension ImageRegion: Stubbable {
    class func stub(values: [String: AnyObject]?) -> ImageRegion {
        return ImageRegion(
            asset: values?["asset"] as? Asset,
            alt: values?["alt"] as? String,
            url: values?["url"] as? NSURL
        )
    }
}

extension UnknownRegion: Stubbable {
    class func stub(values: [String: AnyObject]?) -> UnknownRegion {
        return UnknownRegion(name: "no-op")
    }
}

extension Activity: Stubbable {
    class func stub(values: [String: AnyObject]?) -> Activity {

        let subjectTypeString = (values?["subjectType"] as? String) ?? SubjectType.Unknown.rawValue
        let activityKindString = (values?["kind"] as? String) ?? Activity.Kind.Unknown.rawValue

        return Activity(
            activityId: (values?["activityId"] as? String) ?? "1234",
            kind: Activity.Kind(rawValue: activityKindString) ?? Activity.Kind.Unknown,
            subjectType: SubjectType(rawValue: subjectTypeString) ?? SubjectType.Unknown,
            subject: values?["subject"],
            createdAt: (values?["createdAt"] as? NSDate) ?? NSDate()
        )
    }
}

extension Asset: Stubbable {
    class func stub(values: [String: AnyObject]?) -> Asset {
        return Asset(
            assetId:  (values?["assetId"] as? String) ?? "1234",
            hdpi: values?["hdpi"] as? ImageAttachment,
            xxhdpi: values?["xxhdpi"] as? ImageAttachment
        )
    }
}

extension ImageAttachment: Stubbable {
    class func stub(values: [String: AnyObject]?) -> ImageAttachment {
        return ImageAttachment(
            url: values?["url"] as? NSURL,
            height: values?["height"] as? Int,
            width: values?["width"] as? Int,
            imageType: values?["imageType"] as? String,
            size: values?["size"] as? Int
        )
    }
}

extension Notification: Stubbable {
    class func stub(values: [String: AnyObject]?) -> Notification {

        let author = (values?["author"] as? User)
        let subjectTypeString = (values?["subjectType"] as? String) ?? SubjectType.Unknown.rawValue
        let activityKindString = (values?["kind"] as? String) ?? Activity.Kind.Unknown.rawValue

        return Notification(
            author: author,
            createdAt: (values?["createdAt"] as? NSDate) ?? NSDate(),
            kind: Activity.Kind(rawValue: activityKindString) ?? Activity.Kind.Unknown,
            notificationId: (values?["notificationId"] as? String) ?? "444",
            subjectType: SubjectType(rawValue: subjectTypeString) ?? SubjectType.Unknown
        )
    }
}



