//
//  ContentFlagger.swift
//  Ello
//
//  Created by Sean on 2/25/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

class ContentFlagger {

    let presentingController: UIViewController
    let post: Post

    init(presentingController: UIViewController, post: Post) {
        self.presentingController = presentingController
        self.post = post
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
            case Spam: return "Spam"
            case Violence: return "violence"
            default: return "Mah"

            }
        }

        static let all = [Spam, Violence, Copyright, Threatening, Hate, Adult, DontLike]

    }

    func handler(action: UIAlertAction!) {
        let option = AlertOption(rawValue: action.title)
        if let option = option {
            println(option.name)
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