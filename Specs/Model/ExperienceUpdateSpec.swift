//
//  ExperienceUpdateSpec.swift
//  Ello
//
//  Created by Sean on 4/16/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble

class ExperienceUpdateSpec: QuickSpec {
    override func spec() {

        describe("affectsItem(_:)") {

            context(".CommentChanged") {

                let parentPost: Post = stub(["postId" : "123"])
                let comment: Comment = stub(["commentId" : "362","parentPost" : parentPost])

                let item = StreamCellItem(jsonable: comment, type: .CreateComment, data: nil, oneColumnCellHeight: 5, multiColumnCellHeight: 5, isFullWidth: true)

                context("the item's comment's parent post and/or item's comment is changed") {

                    it("returns true") {
                        let parentPostUpdate = ExperienceUpdate.CommentChanged(commentId: "555", postId: "123", change: ContentChange.Update)
                        expect(parentPostUpdate.affectsItem(item)) == true

                        let commentUpdate = ExperienceUpdate.CommentChanged(commentId: "362", postId: "963", change: ContentChange.Update)
                        expect(commentUpdate.affectsItem(item)) == true
                    }
                }

                context("the item's comment is not changed and/or the item's parent post is not changed") {

                    it("returns false") {
                        let update = ExperienceUpdate.CommentChanged(commentId: "1000", postId: "2000", change: ContentChange.Update)
                        expect(update.affectsItem(item)) == false
                    }
                }
            }

            context(".ContentActionRuleChanged") {

                let user: User = stub(["id" : "232"])
                let postAuthor: User = stub(["id" : "96"])
                let post: Post = stub(["postId" : "123", "author" : postAuthor])
                let commentAuthor: User = stub(["id" : "111"])
                let comment: Comment = stub(["commentId" : "362", "parentPost" : post, "author" : commentAuthor])

                let userItem = StreamCellItem(jsonable: user, type: StreamCellType.ProfileHeader, data: nil, oneColumnCellHeight: 0.0, multiColumnCellHeight: 0.0, isFullWidth: true)

                let postItem = StreamCellItem(jsonable: post, type: StreamCellType.Header, data: nil, oneColumnCellHeight: 0.0, multiColumnCellHeight: 0.0, isFullWidth: true)

                let commentItem = StreamCellItem(jsonable: comment, type: StreamCellType.Header, data: nil, oneColumnCellHeight: 0.0, multiColumnCellHeight: 0.0, isFullWidth: true)

                context("a content action is changed that affects the user") {

                    it("returns true") {
                        let actionChangeUpdate = ExperienceUpdate.ContentActionRuleChanged(userId: "232", action: .Commenting, allowed: true)
                        expect(actionChangeUpdate.affectsItem(userItem)) == true

                        let actionChangeUpdate2 = ExperienceUpdate.ContentActionRuleChanged(userId: "96", action: .Commenting, allowed: true)
                        expect(actionChangeUpdate2.affectsItem(postItem)) == true

                        let actionChangeUpdate3 = ExperienceUpdate.ContentActionRuleChanged(userId: "111", action: .Commenting, allowed: true)
                        expect(actionChangeUpdate3.affectsItem(commentItem)) == true
                    }
                }

                context("a content action is changed that DOES not affects the user") {

                    it("returns false") {
                        let actionChangeUpdate = ExperienceUpdate.ContentActionRuleChanged(userId: "5", action: .Commenting, allowed: true)
                        expect(actionChangeUpdate.affectsItem(userItem)) == false

                        let actionChangeUpdate2 = ExperienceUpdate.ContentActionRuleChanged(userId: "6", action: .Commenting, allowed: true)
                        expect(actionChangeUpdate2.affectsItem(postItem)) == false

                        let actionChangeUpdate3 = ExperienceUpdate.ContentActionRuleChanged(userId: "7", action: .Commenting, allowed: true)
                        expect(actionChangeUpdate3.affectsItem(commentItem)) == false
                    }
                }
            }

            context(".ContentVisibilityRuleChanged") {

                let user: User = stub(["id" : "232"])
                let postAuthor: User = stub(["id" : "96"])
                let post: Post = stub(["postId" : "123", "author" : postAuthor])
                let commentAuthor: User = stub(["id" : "111"])
                let comment: Comment = stub(["commentId" : "362", "parentPost" : post, "author" : commentAuthor])

                let userItem = StreamCellItem(jsonable: user, type: StreamCellType.ProfileHeader, data: nil, oneColumnCellHeight: 0.0, multiColumnCellHeight: 0.0, isFullWidth: true)

                let postItem = StreamCellItem(jsonable: post, type: StreamCellType.Header, data: nil, oneColumnCellHeight: 0.0, multiColumnCellHeight: 0.0, isFullWidth: true)

                let commentItem = StreamCellItem(jsonable: comment, type: StreamCellType.Header, data: nil, oneColumnCellHeight: 0.0, multiColumnCellHeight: 0.0, isFullWidth: true)

                context("a content visibility rule is changed that affects the user") {

                    it("returns true") {
                        let viibilityChangeUpdate = ExperienceUpdate.ContentVisibilityRuleChanged(userId: "232", kind: .NSFW, visible: true)
                        expect(viibilityChangeUpdate.affectsItem(userItem)) == true

                        let viibilityChangeUpdate2 = ExperienceUpdate.ContentVisibilityRuleChanged(userId: "96", kind: .NSFW, visible: true)
                        expect(viibilityChangeUpdate2.affectsItem(postItem)) == true

                        let viibilityChangeUpdate3 = ExperienceUpdate.ContentVisibilityRuleChanged(userId: "111", kind: .NSFW, visible: true)
                        expect(viibilityChangeUpdate3.affectsItem(commentItem)) == true
                    }
                }

                context("a content visibility rule is changed that DOES not affects the user") {

                    it("returns false") {
                        let viibilityChangeUpdate = ExperienceUpdate.ContentVisibilityRuleChanged(userId: "5", kind: .NSFW, visible: true)
                        expect(viibilityChangeUpdate.affectsItem(userItem)) == false

                        let viibilityChangeUpdate2 = ExperienceUpdate.ContentVisibilityRuleChanged(userId: "6", kind: .NSFW, visible: true)
                        expect(viibilityChangeUpdate2.affectsItem(postItem)) == false

                        let viibilityChangeUpdate3 = ExperienceUpdate.ContentVisibilityRuleChanged(userId: "7", kind: .NSFW, visible: true)
                        expect(viibilityChangeUpdate3.affectsItem(commentItem)) == false
                    }
                }
            }

            context(".PostChanged") {

                let post: Post = stub(["postId" : "485"])

                let item = StreamCellItem(jsonable: post, type: .Header, data: nil, oneColumnCellHeight: 5, multiColumnCellHeight: 5, isFullWidth: true)

                context("the item's post IS changed") {

                    it("returns true") {
                        let update = ExperienceUpdate.PostChanged(id: "485", change: ContentChange.Update)
                        expect(update.affectsItem(item)) == true
                    }
                }

                context("the item's post is NOT changed") {

                    it("returns false") {
                        let update = ExperienceUpdate.PostChanged(id: "333", change: ContentChange.Update)
                        expect(update.affectsItem(item)) == false
                    }
                }
            }

            context(".RelationshipChanged") {

                let user: User = stub(["id" : "232"])
                let postAuthor: User = stub(["id" : "96"])
                let post: Post = stub(["postId" : "123", "author" : postAuthor])
                let commentAuthor: User = stub(["id" : "111"])
                let comment: Comment = stub(["commentId" : "362", "parentPost" : post, "author" : commentAuthor])

                let userItem = StreamCellItem(jsonable: user, type: StreamCellType.ProfileHeader, data: nil, oneColumnCellHeight: 0.0, multiColumnCellHeight: 0.0, isFullWidth: true)

                let postItem = StreamCellItem(jsonable: post, type: StreamCellType.Header, data: nil, oneColumnCellHeight: 0.0, multiColumnCellHeight: 0.0, isFullWidth: true)

                let commentItem = StreamCellItem(jsonable: comment, type: StreamCellType.Header, data: nil, oneColumnCellHeight: 0.0, multiColumnCellHeight: 0.0, isFullWidth: true)

                context("the item's user is not part of the block") {

                    it("returns true") {
                        let relationshipUpdate = ExperienceUpdate.RelationshipChanged(relationship: .Friend, userId: "232")
                        expect(relationshipUpdate.affectsItem(userItem)) == true

                        let relationshipUpdate2 = ExperienceUpdate.RelationshipChanged(relationship: .Friend, userId: "96")
                        expect(relationshipUpdate2.affectsItem(postItem)) == true

                        let relationshipUpdate3 = ExperienceUpdate.RelationshipChanged(relationship: .Friend, userId: "111")
                        expect(relationshipUpdate3.affectsItem(commentItem)) == true
                    }
                }

                context("the item's user is part of the block") {

                    it("returns false") {
                        let relationshipUpdate = ExperienceUpdate.RelationshipChanged(relationship: .Friend, userId: "asdf")
                        expect(relationshipUpdate.affectsItem(userItem)) == false

                        let relationshipUpdate2 = ExperienceUpdate.RelationshipChanged(relationship: .Friend, userId: "ghjk")
                        expect(relationshipUpdate2.affectsItem(postItem)) == false

                        let relationshipUpdate3 = ExperienceUpdate.RelationshipChanged(relationship: .Friend, userId: "1234")
                        expect(relationshipUpdate3.affectsItem(commentItem)) == false
                    }
                }
            }

            context(".UserBlocked") {

                let user: User = stub(["id" : "232"])
                let postAuthor: User = stub(["id" : "96"])
                let post: Post = stub(["postId" : "123", "author" : postAuthor])
                let commentAuthor: User = stub(["id" : "111"])
                let comment: Comment = stub(["commentId" : "362", "parentPost" : post, "author" : commentAuthor])

                let userItem = StreamCellItem(jsonable: user, type: StreamCellType.ProfileHeader, data: nil, oneColumnCellHeight: 0.0, multiColumnCellHeight: 0.0, isFullWidth: true)

                let postItem = StreamCellItem(jsonable: post, type: StreamCellType.Header, data: nil, oneColumnCellHeight: 0.0, multiColumnCellHeight: 0.0, isFullWidth: true)

                let commentItem = StreamCellItem(jsonable: comment, type: StreamCellType.Header, data: nil, oneColumnCellHeight: 0.0, multiColumnCellHeight: 0.0, isFullWidth: true)

                context("the item's user is not part of the block") {

                    it("returns true") {
                        let blockedUpdate = ExperienceUpdate.UserBlocked(id: "232", blocked: true)
                        expect(blockedUpdate.affectsItem(userItem)) == true

                        let blockedUpdate2 = ExperienceUpdate.UserBlocked(id: "96", blocked: true)
                        expect(blockedUpdate2.affectsItem(postItem)) == true

                        let blockedUpdate3 = ExperienceUpdate.UserBlocked(id: "111", blocked: true)
                        expect(blockedUpdate3.affectsItem(commentItem)) == true
                    }
                }

                context("the item's user is part of the block") {

                    it("returns false") {
                        let blockedUpdate = ExperienceUpdate.UserBlocked(id: "59", blocked: true)
                        expect(blockedUpdate.affectsItem(userItem)) == false

                        let blockedUpdate2 = ExperienceUpdate.UserBlocked(id: "12", blocked: true)
                        expect(blockedUpdate2.affectsItem(postItem)) == false

                        let blockedUpdate3 = ExperienceUpdate.UserBlocked(id: "abc", blocked: true)
                        expect(blockedUpdate3.affectsItem(commentItem)) == false
                    }
                }
            }

            context(".UserMuted") {

                let user: User = stub(["id" : "232"])
                let postAuthor: User = stub(["id" : "96"])
                let post: Post = stub(["postId" : "123", "author" : postAuthor])
                let commentAuthor: User = stub(["id" : "111"])
                let comment: Comment = stub(["commentId" : "362", "parentPost" : post, "author" : commentAuthor])

                let userItem = StreamCellItem(jsonable: user, type: StreamCellType.ProfileHeader, data: nil, oneColumnCellHeight: 0.0, multiColumnCellHeight: 0.0, isFullWidth: true)

                let postItem = StreamCellItem(jsonable: post, type: StreamCellType.Header, data: nil, oneColumnCellHeight: 0.0, multiColumnCellHeight: 0.0, isFullWidth: true)

                let commentItem = StreamCellItem(jsonable: comment, type: StreamCellType.Header, data: nil, oneColumnCellHeight: 0.0, multiColumnCellHeight: 0.0, isFullWidth: true)

                it("returns false") {
                    let blockedUpdate = ExperienceUpdate.UserMuted(id: "232", muted: true)
                    expect(blockedUpdate.affectsItem(userItem)) == false

                    let blockedUpdate2 = ExperienceUpdate.UserMuted(id: "96", muted: true)
                    expect(blockedUpdate2.affectsItem(postItem)) == false

                    let blockedUpdate3 = ExperienceUpdate.UserMuted(id: "111", muted: true)
                    expect(blockedUpdate3.affectsItem(commentItem)) == false
                }
            }
        }
    }
}
