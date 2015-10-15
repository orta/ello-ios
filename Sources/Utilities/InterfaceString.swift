//
//  InterfaceString.swift
//  Ello
//
//  Created by Sean on 10/13/15.
//  Copyright © 2015 Ello. All rights reserved.
//

public enum InterfaceString {

    public enum Followers {
        case CurrentUserNoResultsBody
        case CurrentUserNoResultsTitle
        case NoResultsBody
        case NoResultsTitle
        case Title

        var localized: String {
            switch self {
            case .CurrentUserNoResultsBody:
                return NSLocalizedString("Here's some tips on how to get new followers: use Discover to find people you're interested in, and to find or invite your friends. When you see things you like you can comment, repost, mention people and love the posts that you most enjoy. ", comment: "Current user no followers results body.")
            case .CurrentUserNoResultsTitle:
                return NSLocalizedString("You don't have any followers yet!", comment: "Current user no followers results title")
            case .NoResultsBody:
                return NSLocalizedString("Be the first to follow them and give them some love! Following interesting people makes Ello way more fun.", comment: "Non-current user following no results body")
            case .NoResultsTitle:
                return NSLocalizedString("This person doesn't have any followers yet! ", comment: "Non-current user followers no results title")
            case .Title:
                return NSLocalizedString("Followers", comment: "Followers title")
            }
        }
    }

    public enum Following {
        case CurrentUserNoResultsBody
        case CurrentUserNoResultsTitle
        case NoResultsBody
        case NoResultsTitle
        case Title

        var localized: String {
            switch self {
            case .CurrentUserNoResultsBody:
                return NSLocalizedString("Ello is way more rad when you're following lots of people.\n\nUse Discover to find people you're interested in, and to find or invite your friends.\nYou can also use Search (upper right) to look for new and excellent people!", comment: "Current user No following results body.")
            case .CurrentUserNoResultsTitle:
                return NSLocalizedString("You aren't following anyone yet!", comment: "Current user no following results title")
            case .NoResultsBody:
                return NSLocalizedString("Follow, mention them, comment, repost or love one of their posts and maybe they'll follow you back ;)", comment: "Non-current user following no results body")
            case .NoResultsTitle:
                return NSLocalizedString("This person isn't following anyone yet!", comment: "Non-current user followoing no results title")
            case .Title:
                return NSLocalizedString("Following", comment: "Following title")
            }
        }
    }

    public enum Loves {
        case CurrentUserNoResultsBody
        case CurrentUserNoResultsTitle
        case NoResultsBody
        case NoResultsTitle
        case Title

        var localized: String {
            switch self {
            case .CurrentUserNoResultsBody:
                return NSLocalizedString("You can use Ello Loves as a way to bookmark the things you care about most. Go Love someone's post, and it will be added to this stream.", comment: "Current user no loves results body.")
            case .CurrentUserNoResultsTitle:
                return NSLocalizedString("You haven't Loved any posts yet!", comment: "Current user no loves results title")
            case .NoResultsBody:
                return NSLocalizedString("Ello Loves are a way to bookmark the things you care about most. When they love something the posts will appear here.", comment: "Non-current user no loves results body.")
            case .NoResultsTitle:
                return NSLocalizedString("This person hasn’t Loved any posts yet!", comment: "Non-current user no loves results title")
            case .Title:
                return NSLocalizedString("Loves", comment: "love stream")
            }
        }
    }
    
}
