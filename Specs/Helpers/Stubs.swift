//
//  Stubs.swift
//  Ello
//
//  Created by Ryan Boyajian on 3/6/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Ello


func stub<T: Stubbable>(values: [String : AnyObject]) -> T {
    return T.stub(values)
}

func urlFromValue(_ value: AnyObject? = nil) -> NSURL? {
    if value == nil { return nil }
    else if let url = value as? NSURL {
        return url
    } else if let str = value as? String {
        return NSURL(string: str)
    }
    return nil
}

let stubbedTextRegion: TextRegion = stub([:])

protocol Stubbable: NSObjectProtocol {
    static func stub(values: [String : AnyObject]) -> Self
}

extension User: Stubbable {
    class func stub(values: [String : AnyObject]) -> User {

        let relationship = (values["relationshipPriority"] as? String).map {
            RelationshipPriority(stringValue: $0)
        } ?? RelationshipPriority.None

        var user =  User(
            id: (values["id"] as? String) ?? "stub-user-id",
            href: (values["href"] as? String) ?? "href",
            username: (values["username"] as? String) ?? "username",
            name: (values["name"] as? String) ?? "name",
            experimentalFeatures: (values["experimentalFeatures"] as? Bool) ?? false,
            relationshipPriority: relationship,
            postsAdultContent: (values["postsAdultContent"] as? Bool) ?? false,
            viewsAdultContent: (values["viewsAdultContent"] as? Bool) ?? false,
            hasCommentingEnabled: (values["hasCommentingEnabled"] as? Bool) ?? true,
            hasSharingEnabled: (values["hasSharingEnabled"] as? Bool) ?? true,
            hasRepostingEnabled: (values["hasRepostingEnabled"] as? Bool) ?? true,
            hasLovesEnabled: (values["hasLovesEnabled"] as? Bool) ?? true
        )
        user.avatar = values["avatar"] as? Asset
        user.identifiableBy = (values["identifiableBy"] as? String) ?? "stub-user-identifiable-by"
        user.postsCount = (values["postsCount"] as? Int) ?? 0
        user.lovesCount = (values["lovesCount"] as? Int) ?? 0
        user.followersCount = (values["followersCount"] as? String) ?? "stub-user-followers-count"
        user.followingCount = (values["followingCount"] as? Int) ?? 0
        user.formattedShortBio = (values["formattedShortBio"] as? String) ?? "stub-user-formatted-short-bio"
        user.externalLinksList = (values["externalLinksList"] as? [[String:String]]) ?? [["text": "ello.co", "url": "http://ello.co"]]
        user.coverImage = values["coverImage"] as? Asset
        user.backgroundPosition = (values["backgroundPosition"] as? String) ?? "stub-user-background-position"
        // links / nested resources
        if let posts = values["posts"] as? [Post] {
            var postIds = [String]()
            for post in posts {
                postIds.append(post.id)
                ElloLinkedStore.sharedInstance.setObject(post, forKey: post.id, inCollection: MappingType.PostsType.rawValue)
            }
            user.addLinkArray("posts", array: postIds)
        }
        if let mostRecentPost = values["mostRecentPost"] as? Post {
            user.addLinkObject("most_recent_post", key: mostRecentPost.id, collection: MappingType.PostsType.rawValue)
            ElloLinkedStore.sharedInstance.setObject(mostRecentPost, forKey: mostRecentPost.id, inCollection: MappingType.PostsType.rawValue)
        }
        user.profile = values["profile"] as? Profile
        ElloLinkedStore.sharedInstance.setObject(user, forKey: user.id, inCollection: MappingType.UsersType.rawValue)
        return user
    }
}

extension Love: Stubbable {
    class func stub(values: [String : AnyObject]) -> Love {

        // create necessary links

        let post: Post = (values["post"] as? Post) ?? Post.stub(["id": values["postId"] ?? "stub-post-id"])
        ElloLinkedStore.sharedInstance.setObject(post, forKey: post.id, inCollection: MappingType.PostsType.rawValue)

        let user: User = (values["user"] as? User) ?? User.stub(["id": values["userId"] ?? "stub-user-id"])
        ElloLinkedStore.sharedInstance.setObject(user, forKey: user.id, inCollection: MappingType.UsersType.rawValue)

        var love = Love(
            id: (values["id"] as? String) ?? "stub-love-id",
            createdAt: (values["createdAt"] as? NSDate) ?? NSDate(),
            updatedAt: (values["updatedAt"] as? NSDate) ?? NSDate(),
            deleted: (values["deleted"] as? Bool) ?? true,
            postId: (values["postId"] as? String) ?? "stub-post-id",
            userId: (values["userId"] as? String) ?? "stub-user-id"
        )

        return love
    }
}

extension Profile: Stubbable {
    class func stub(values: [String : AnyObject]) -> Profile {
        var profile = Profile(
            createdAt: (values["createdAt"] as? NSDate) ?? NSDate(),
            shortBio: (values["shortBio"] as? String) ?? "shortBio",
            email: (values["email"] as? String) ?? "email@example.com",
            confirmedAt: (values["confirmedAt"] as? NSDate) ?? NSDate(),
            isPublic: (values["isPublic"] as? Bool) ?? true,
            hasAdNotificationsEnabled: (values["hasAdNotificationsEnabled"] as? Bool) ?? true,
            allowsAnalytics: (values["allowsAnalytics"] as? Bool) ?? true,
            notifyOfCommentsViaEmail: (values["notifyOfCommentsViaEmail"] as? Bool) ?? true,
            notifyOfLovesViaEmail: (values["notifyOfLovesViaEmail"] as? Bool) ?? true,
            notifyOfInvitationAcceptancesViaEmail: (values["notifyOfInvitationAcceptancesViaEmail"] as? Bool) ?? true,
            notifyOfMentionsViaEmail: (values["notifyOfMentionsViaEmail"] as? Bool) ?? true,
            notifyOfNewFollowersViaEmail: (values["notifyOfNewFollowersViaEmail"] as? Bool) ?? true,
            notifyOfRepostsViaEmail: (values["notifyOfRepostsViaEmail"] as? Bool) ?? true,
            subscribeToUsersEmailList: (values["subscribeToUsersEmailList"] as? Bool) ?? true,
            notifyOfCommentsViaPush: (values["notifyOfCommentsViaPush"] as? Bool) ?? true,
            notifyOfLovesViaPush : (values["notifyOfLovesViaPush"] as? Bool) ?? true,
            notifyOfMentionsViaPush: (values["notifyOfMentionsViaPush"] as? Bool) ?? true,
            notifyOfRepostsViaPush: (values["notifyOfRepostsViaPush"] as? Bool) ?? true,
            notifyOfNewFollowersViaPush: (values["notifyOfNewFollowersViaPush"] as? Bool) ?? true,
            notifyOfInvitationAcceptancesViaPush: (values["notifyOfInvitationAcceptancesViaPush"] as? Bool) ?? true,
            discoverable: (values["discoverable"] as? Bool) ?? true
        )
        return profile
    }
}

extension Post: Stubbable {
    class func stub(values: [String : AnyObject]) -> Post {

        // create necessary links

        let author: User = (values["author"] as? User) ?? User.stub(["id": values["authorId"] ?? "stub-author-id"])
        ElloLinkedStore.sharedInstance.setObject(author, forKey: author.id, inCollection: MappingType.UsersType.rawValue)

        var post = Post(
            id: (values["id"] as? String) ?? "stub-post-id",
            createdAt: (values["createdAt"] as? NSDate) ?? NSDate(),
            authorId: author.id,
            href: (values["href"] as? String) ?? "sample-href",
            token: (values["token"] as? String) ?? "sample-token",
            contentWarning: (values["contentWarning"] as? String) ?? "",
            allowComments: (values["allowComments"] as? Bool) ?? false,
            reposted: (values["reposted"] as? Bool) ?? false,
            loved: (values["loved"] as? Bool) ?? false,
            summary: (values["summary"] as? [Regionable]) ?? [stubbedTextRegion]
        )

        // optional
        post.content = (values["content"] as? [Regionable]) ?? [stubbedTextRegion]
        post.repostContent = (values["repostContent"] as? [Regionable])
        post.repostId = (values["repostId"] as? String)
        post.repostPath = (values["repostPath"] as? String)
        post.repostViaId = (values["repostViaId"] as? String)
        post.repostViaPath = (values["repostViaPath"] as? String)
        post.viewsCount = values["viewsCount"] as? Int
        post.commentsCount = values["commentsCount"] as? Int
        post.repostsCount = values["repostsCount"] as? Int
        post.lovesCount = values["lovesCount"] as? Int
        // links / nested resources
        if let assets = values["assets"] as? [Asset] {
            var assetIds = [String]()
            for asset in assets {
                assetIds.append(asset.id)
                ElloLinkedStore.sharedInstance.setObject(asset, forKey: asset.id, inCollection: MappingType.AssetsType.rawValue)
            }
            post.addLinkArray("assets", array: assetIds)
        }
        if let comments = values["comments"] as? [Comment] {
            var commentIds = [String]()
            for comment in comments {
                commentIds.append(comment.id)
                ElloLinkedStore.sharedInstance.setObject(comment, forKey: comment.id, inCollection: MappingType.CommentsType.rawValue)
            }
            post.addLinkArray("comments", array: commentIds)
        }
        ElloLinkedStore.sharedInstance.setObject(post, forKey: post.id, inCollection: MappingType.PostsType.rawValue)
        return post
    }

    class func stubWithRegions(values: [String : AnyObject], summary: [Regionable] = [], content: [Regionable] = []) -> Post {
        var mutatedValues = values
        mutatedValues.updateValue(summary, forKey: "summary")
        var post: Post = stub(mutatedValues)
        post.content = content
        return post
    }

}

extension Comment: Stubbable {
    class func stub(values: [String : AnyObject]) -> Comment {

        // create necessary links
        let author: User = (values["author"] as? User) ?? User.stub(["id": values["authorId"] ?? "stub-comment-author-id"])
        ElloLinkedStore.sharedInstance.setObject(author, forKey: author.id, inCollection: MappingType.UsersType.rawValue)
        let parentPost: Post = (values["parentPost"] as? Post) ?? Post.stub(["id": values["parentPostId"] ?? "stub-comment-parent-post-id"])
        ElloLinkedStore.sharedInstance.setObject(parentPost, forKey: parentPost.id, inCollection: MappingType.PostsType.rawValue)

        var comment = Comment(
            id: (values["id"] as? String) ?? "test-comment-id",
            createdAt: (values["createdAt"] as? NSDate) ?? NSDate(),
            authorId: author.id,
            postId: parentPost.id,
            content: (values["content"] as? [Regionable]) ?? [stubbedTextRegion]
        )

        // links
        if let assets = values["assets"] as? [Asset] {
            var assetIds = [String]()
            for asset in assets {
                assetIds.append(asset.id)
                ElloLinkedStore.sharedInstance.setObject(asset, forKey: asset.id, inCollection: MappingType.AssetsType.rawValue)
            }
            comment.addLinkArray("assets", array: assetIds)
        }
        ElloLinkedStore.sharedInstance.setObject(comment, forKey: comment.id, inCollection: MappingType.CommentsType.rawValue)
        return comment
    }
}

extension TextRegion: Stubbable {
    class func stub(values: [String : AnyObject]) -> TextRegion {
        return TextRegion(
            content: (values["content"] as? String) ?? "Lorem Ipsum"
        )
    }
}

extension ImageRegion: Stubbable {
    class func stub(values: [String : AnyObject]) -> ImageRegion {
        var imageRegion = ImageRegion(alt: (values["alt"] as? String) ?? "imageRegion")
        imageRegion.url = urlFromValue(values["url"])
        if let asset = values["asset"] as? Asset {
            imageRegion.addLinkObject("assets", key: asset.id, collection: MappingType.AssetsType.rawValue)
            ElloLinkedStore.sharedInstance.setObject(asset, forKey: asset.id, inCollection: MappingType.AssetsType.rawValue)
        }
        return imageRegion
    }
}

extension UnknownRegion: Stubbable {
    class func stub(values: [String : AnyObject]) -> UnknownRegion {
        return UnknownRegion(name: "no-op")
    }
}

extension Activity: Stubbable {
    class func stub(values: [String : AnyObject]) -> Activity {

        let activityKindString = (values["kind"] as? String) ?? Activity.Kind.FriendPost.rawValue
        let subjectTypeString = (values["subjectType"] as? String) ?? SubjectType.Post.rawValue

        let activity = Activity(
            id: (values["id"] as? String) ?? "stub-activity-id",
            createdAt: (values["createdAt"] as? NSDate) ?? NSDate(),
            kind: Activity.Kind(rawValue: activityKindString) ?? Activity.Kind.FriendPost,
            subjectType: SubjectType(rawValue: subjectTypeString) ?? SubjectType.Post
        )

        if let user = values["subject"] as? User {
            activity.addLinkObject("subject", key: user.id, collection: MappingType.UsersType.rawValue)
            ElloLinkedStore.sharedInstance.setObject(user, forKey: user.id, inCollection: MappingType.UsersType.rawValue)
        }
        else if let post = values["subject"] as? Post {
            activity.addLinkObject("subject", key: post.id, collection: MappingType.PostsType.rawValue)
            ElloLinkedStore.sharedInstance.setObject(post, forKey: post.id, inCollection: MappingType.PostsType.rawValue)
        }
        else if let comment = values["subject"] as? Comment {
            activity.addLinkObject("subject", key: comment.id, collection: MappingType.CommentsType.rawValue)
            ElloLinkedStore.sharedInstance.setObject(comment, forKey: comment.id, inCollection: MappingType.CommentsType.rawValue)
        }
        ElloLinkedStore.sharedInstance.setObject(activity, forKey: activity.id, inCollection: MappingType.ActivitiesType.rawValue)
        return activity
    }
}

extension Asset: Stubbable {
    class func stub(values: [String : AnyObject]) -> Asset {
        var asset = Asset(id: (values["id"] as? String) ?? "stub-asset-id")
        asset.optimized = values["optimized"] as? Attachment
        asset.smallScreen = values["smallScreen"] as? Attachment
        asset.ldpi = values["ldpi"] as? Attachment
        asset.mdpi = values["mdpi"] as? Attachment
        asset.hdpi = values["hdpi"] as? Attachment
        asset.xhdpi = values["xhdpi"] as? Attachment
        asset.xxhdpi = values["xxhdpi"] as? Attachment
        asset.original = values["original"] as? Attachment
        asset.large = values["large"] as? Attachment
        asset.regular = values["regular"] as? Attachment
        asset.small = values["small"] as? Attachment
        ElloLinkedStore.sharedInstance.setObject(asset, forKey: asset.id, inCollection: MappingType.AssetsType.rawValue)
        return asset
    }
}

extension Attachment: Stubbable {
    class func stub(values: [String : AnyObject]) -> Attachment {
        var attachment = Attachment(url: urlFromValue(values["url"]) ?? NSURL(string: "http://www.google.com")!)
        attachment.height = values["height"] as? Int
        attachment.width = values["width"] as? Int
        attachment.type = values["type"] as? String
        attachment.size = values["size"] as? Int
        return attachment
    }
}

extension Notification: Stubbable {
    class func stub(values: [String : AnyObject]) -> Notification {
        return Notification(activity: (values["activity"] as? Activity) ?? Activity.stub([:]))
    }
}

extension Relationship: Stubbable {
    class func stub(values: [String : AnyObject]) -> Relationship {
        // create necessary links
        let owner: User = (values["owner"] as? User) ?? User.stub(["relationshipPriority": "self", "id": values["ownerId"] ?? "stub-relationship-owner-id"])
        ElloLinkedStore.sharedInstance.setObject(owner, forKey: owner.id, inCollection: MappingType.UsersType.rawValue)
        let subject: User = (values["subject"] as? User) ?? User.stub(["relationshipPriority": "friend", "id": values["subjectId"] ?? "stub-relationship-subject-id"])
        ElloLinkedStore.sharedInstance.setObject(owner, forKey: owner.id, inCollection: MappingType.UsersType.rawValue)

        return Relationship(
            id: (values["id"] as? String) ?? "stub-relationship-id",
            createdAt: (values["createdAt"] as? NSDate) ?? NSDate(),
            ownerId: owner.id,
            subjectId: subject.id
        )
    }
}
