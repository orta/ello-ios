//

//  ContentFlagger.swift
//  Ello
//
//  Created by Sean on 2/25/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

public class ContentFlagger {

    var contentFlagged:Bool?

    weak public var presentingController: UIViewController?
    let flaggableId: String
    let contentType: ContentType
    var commentPostId: String?

    public init(presentingController: UIViewController?, flaggableId: String, contentType: ContentType, commentPostId:String?) {
        self.presentingController = presentingController
        self.flaggableId = flaggableId
        self.contentType = contentType
        self.commentPostId = commentPostId
    }

    public enum AlertOption: String {
        case Spam = "Spam"
        case Violence = "Violence"
        case Copyright = "Copyright infringement"
        case Threatening = "Threatening"
        case Hate = "Hate Speech"
        case Adult = "NSFW Content"
        case DontLike = "I don't like it"

        public var name: String {
            return self.rawValue
        }

        public var kind: String {
            switch self {
            case Spam: return "spam"
            case Violence: return "violence"
            case Copyright: return "copyright"
            case Threatening: return "threatening"
            case Hate: return "hate_speech"
            case Adult: return "adult"
            case DontLike: return "offensive"
            }
        }

        static let all = [Spam, Violence, Copyright, Threatening, Hate, Adult, DontLike]
    }

    func handler(action: AlertAction) {
        let option = AlertOption(rawValue: action.title)
        if let option = option {

            var endPoint:ElloAPI
            switch contentType {
            case .Post:
                endPoint = ElloAPI.FlagPost(postId: flaggableId, kind: option.kind)
            case .Comment:
                endPoint = ElloAPI.FlagComment(postId: commentPostId!, commentId: flaggableId, kind: option.kind)
            }

            let service = ContentFlaggingService()
            service.flagContent(endPoint, success: {
                Tracker.sharedTracker.contentFlagged(self.contentType, flag: option)
                self.contentFlagged = true
            }, failure: { (error, statusCode) in
                Tracker.sharedTracker.contentCreationFailed(self.contentType, message: error.localizedDescription)
                self.contentFlagged = false
            })
        }
    }

    public func displayFlaggingSheet() {

        let alertController = AlertViewController(message: "Would you like to flag this content as:", textAlignment: .Left)

        for option in AlertOption.all {
            let action = AlertAction(title: option.name, style: .Dark, handler: handler)
            alertController.addAction(action)
        }

        let cancelAction = AlertAction(title: "Cancel", style: .Light) { _ in
            Tracker.sharedTracker.contentFlaggingCanceled(self.contentType)
        }

        alertController.addAction(cancelAction)

        presentingController?.presentViewController(alertController, animated: true, completion: .None)
    }

}
