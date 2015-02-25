//
//  ContentFlaggerSpec.swift
//  Ello
//
//  Created by Sean on 2/25/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Quick
import Nimble
import Moya


class ContentFlaggerSpec: QuickSpec {

    override func spec() {

        var subject: ContentFlagger!
        var presentingController = UIViewController()
        beforeEach({

            let keyWindow = UIWindow(frame: UIScreen.mainScreen().bounds)
            keyWindow.makeKeyAndVisible()
            keyWindow.rootViewController = presentingController
            presentingController.loadView()
            presentingController.viewDidLoad()
        })

        context("post flagging") {

            beforeEach({
                subject = ContentFlagger(presentingController: presentingController,
                    flaggableId: "123",
                    flaggableContentType: .Post,
                    commentPostId: nil)
            })

            it("presents a UIAlertController in ActionSheet mode") {

                subject.displayFlaggingSheet()
                let presentedVC = subject.presentingController.presentedViewController as UIAlertController

                expect(presentedVC).to(beAKindOf(UIAlertController.self))
                expect(presentedVC.preferredStyle) == UIAlertControllerStyle.ActionSheet
            }

            it("has actions for all 8 types of flagging") {
                subject.displayFlaggingSheet()
                let presentedVC = subject.presentingController.presentedViewController as UIAlertController

                let actions = presentedVC.actions
                expect(countElements(actions)) == 8
                let spamAction = actions[0] as UIAlertAction
                let violenceAction = actions[1] as UIAlertAction
                let copyrightAction = actions[2] as UIAlertAction
                let threateningAction = actions[3] as UIAlertAction
                let hateAction = actions[4] as UIAlertAction
                let adultAction = actions[5] as UIAlertAction
                let dontLikeAction = actions[6] as UIAlertAction
                let cancelAction = actions[7] as UIAlertAction

                expect(spamAction.title) == "Spam"
                expect(violenceAction.title) == "Violence"
                expect(copyrightAction.title) == "Copyright infringement"
                expect(threateningAction.title) == "Threatening"
                expect(hateAction.title) == "Hate Speech"
                expect(adultAction.title) == "Adult content that isn't marked NSFW*"
                expect(dontLikeAction.title) == "I don't like it"
                expect(cancelAction.title) == "Cancel"
            }

            it("the correct kind is associated with each flag type") {
                subject.displayFlaggingSheet()
                let presentedVC = subject.presentingController.presentedViewController as UIAlertController

                let actions = presentedVC.actions

                let spamAction = actions[0] as UIAlertAction
                let violenceAction = actions[1] as UIAlertAction
                let copyrightAction = actions[2] as UIAlertAction
                let threateningAction = actions[3] as UIAlertAction
                let hateAction = actions[4] as UIAlertAction
                let adultAction = actions[5] as UIAlertAction
                let dontLikeAction = actions[6] as UIAlertAction
                let cancelAction = actions[7] as UIAlertAction

                expect(spamAction.kind) == "Spam"
                expect(violenceAction.title) == "Violence"
                expect(copyrightAction.title) == "Copyright infringement"
                expect(threateningAction.title) == "Threatening"
                expect(hateAction.title) == "Hate Speech"
                expect(adultAction.title) == "Adult content that isn't marked NSFW*"
                expect(dontLikeAction.title) == "I don't like it"
                expect(cancelAction.title) == "Cancel"
            }
            

        }

        context("comment flagging") {

            beforeEach({
                subject = ContentFlagger(presentingController: presentingController,
                    flaggableId: "123",
                    flaggableContentType: .Comment,
                    commentPostId: "5")
            })

            it("presents a UIAlertController in ActionSheet mode") {

                subject.displayFlaggingSheet()
                let presentedVC = subject.presentingController.presentedViewController as UIAlertController

                expect(presentedVC).to(beAKindOf(UIAlertController.self))
                expect(presentedVC.preferredStyle) == UIAlertControllerStyle.ActionSheet
            }


        }

    }

}
