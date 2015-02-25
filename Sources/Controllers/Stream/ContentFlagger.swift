//
//  ContentFlagger.swift
//  Ello
//
//  Created by Sean on 2/25/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

enum FlaggableContentType {
    case Post
    case Comment
}

class ContentFlagger {

    var contentFlagged:Bool?

    let presentingController: UIViewController
    let flaggableId: String
    let flaggableContentType: FlaggableContentType
    var commentPostId: String?

    init(presentingController: UIViewController, flaggableId: String, flaggableContentType: FlaggableContentType, commentPostId:String?) {
        self.presentingController = presentingController
        self.flaggableId = flaggableId
        self.flaggableContentType = flaggableContentType
        self.commentPostId = commentPostId
    }

    enum AlertOption: String {
        case Spam = "Spam"
        case Violence = "Violence"
        case Copyright = "Copyright infringement"
        case Threatening = "Threatening"
        case Hate = "Hate Speech"
        case Adult = "Adult content that isn't marked NSFW*"
        case DontLike = "I don't like it"

        var name: String {
            return self.rawValue
        }

        var kind: String {
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

    func handler(action: UIAlertAction!) {
        let option = AlertOption(rawValue: action.title)
        if let option = option {

            var endPoint:ElloAPI
            switch flaggableContentType {
            case .Post:
                endPoint = ElloAPI.FlagPost(postId: flaggableId, kind: option.kind)
            case .Comment:
                endPoint = ElloAPI.FlagComment(postId: commentPostId!, commentId: flaggableId, kind: option.kind)
            }

            let service = ContentFlaggingService()
            service.flagContent(endPoint, success: {
                self.contentFlagged = true
            }, failure: { (error, statusCode) in
                self.contentFlagged = false
            })

        }
    }

    func displayFlaggingSheet() {

        let alertController = UIAlertController(title: "Would you like to flag this content as:", message: "* Ello allows adult content as long as it complies with our rules and is marked NSFW.", preferredStyle: .ActionSheet)

        for option in AlertOption.all {
            let action = UIAlertAction(title: option.name, style: .Destructive, handler:handler)
            alertController.addAction(action)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            // ...
        }

        alertController.addAction(cancelAction)

        presentingController.presentViewController(alertController, animated: true) {
            // ...
        }
    }

}