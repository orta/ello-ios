//
//  NotificationCellSpec.swift
//  Ello
//
//  Created by Colin Gray on 1/22/2016.
//  Copyright (c) 2016 Ello. All rights reserved.
//

@testable import Ello
import Quick
import Nimble


class NotificationCellSpec: QuickSpec {
    override func spec() {
        describe("NotificationCell") {
            it("should set its titleTextView height") {
                let subject = NotificationCell()
                subject.frame.size = CGSize(width: 320, height: 40)
                let author: User = .stub(["username": "ello"])
                let post: Post = .stub(["authorId": author.id])
                subject.title = NotificationAttributedTitle.attributedTitle(.PostMentionNotification, author: author, subject: post)
                subject.layoutIfNeeded()

                expect(subject.titleTextView.frame.size.height) == 17
            }

            it("should set its titleTextView height") {
                let subject = NotificationCell()
                subject.frame.size = CGSize(width: 160, height: 40)
                let author: User = .stub(["username": "ello"])
                let post: Post = .stub(["authorId": author.id])
                subject.title = NotificationAttributedTitle.attributedTitle(.PostMentionNotification, author: author, subject: post)
                subject.layoutIfNeeded()

                expect(subject.titleTextView.frame.size.height) == 51
            }
        }
    }
}
