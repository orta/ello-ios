//
//  ContentFlaggerSpec.swift
//  Ello
//
//  Created by Sean on 2/25/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble
import Moya


class ContentFlaggerSpec: QuickSpec {

    override func spec() {

        var subject: ContentFlagger!
        let presentingController = UIViewController()
        beforeEach {
            self.showController(presentingController)
        }

        context("post flagging") {

            beforeEach({
                subject = ContentFlagger(presentingController: presentingController,
                    flaggableId: "123",
                    contentType: .Post,
                    commentPostId: nil)
            })

            it("presents an AlertViewController") {

                subject.displayFlaggingSheet()
                let presentedVC = subject.presentingController?.presentedViewController as! AlertViewController

                expect(presentedVC).to(beAKindOf(AlertViewController.self))
            }

            it("the correct kind is associated with each flag type") {
                subject.displayFlaggingSheet()
                let presentedVC = subject.presentingController?.presentedViewController as! AlertViewController

                let actions = presentedVC.actions

                let spamAction = actions[0]
                let violenceAction = actions[1]
                let copyrightAction = actions[2]
                let threateningAction = actions[3]
                let hateAction = actions[4]
                let adultAction = actions[5]
                let dontLikeAction = actions[6]

                expect(ContentFlagger.AlertOption(rawValue: spamAction.title)) == ContentFlagger.AlertOption.Spam
                expect(ContentFlagger.AlertOption(rawValue: violenceAction.title)) == ContentFlagger.AlertOption.Violence
                expect(ContentFlagger.AlertOption(rawValue: copyrightAction.title)) == ContentFlagger.AlertOption.Copyright
                expect(ContentFlagger.AlertOption(rawValue: threateningAction.title)) == ContentFlagger.AlertOption.Threatening
                expect(ContentFlagger.AlertOption(rawValue: hateAction.title)) == ContentFlagger.AlertOption.Hate
                expect(ContentFlagger.AlertOption(rawValue: adultAction.title)) == ContentFlagger.AlertOption.Adult
                expect(ContentFlagger.AlertOption(rawValue: dontLikeAction.title)) == ContentFlagger.AlertOption.DontLike
            }
        }
    }
}
