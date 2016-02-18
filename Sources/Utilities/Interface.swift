//
//  InterfaceString.swift
//  Ello
//
//  Created by Sean on 10/13/15.
//  Copyright © 2015 Ello. All rights reserved.
//

import SVGKit


public enum InterfaceImage: String {
    public enum Style {
        case Normal
        case White
        case Selected
        case Disabled
        case Red
    }

    case ElloLogo = "ello_logo"

    // Postbar Icons
    case Eye = "eye"
    case Heart = "hearts"
    case Repost = "repost"
    case Share = "share"
    case XBox = "xbox"
    case Pencil = "pencil"
    case Reply = "reply"
    case Flag = "flag"

    // Notification Icons
    case Comments = "bubble"
    case Invite = "relationships"

    // TabBar Icons
    case Sparkles = "sparkles"
    case Bolt = "bolt"
    case Omni = "omni"
    case Person = "person"
    case CircBig = "circbig"
    case NarrationPointer = "narration_pointer"

    // Validation States
    case ValidationLoading = "circ"
    case ValidationError = "x_red"
    case ValidationOK = "check_green"

    // NavBar Icons
    case Search = "search"
    case Burger = "burger"

    // Grid/List Icons
    case Grid = "grid"
    case List = "list"

    // Omnibar
    case Reorder = "reorder"
    case Camera = "camera"
    case Check = "check"
    case Arrow = "arrow"
    case Link = "link"
    case BreakLink = "breaklink"

    // Commenting
    case ReplyAll = "replyall"
    case BubbleBody = "bubble_body"
    case BubbleTail = "bubble_tail"

    // Relationship
    case Star = "star"

    // Alert
    case Question = "question"

    // Generic
    case X = "x"
    case Dots = "dots"
    case PlusSmall = "plussmall"
    case CheckSmall = "checksmall"
    case AngleBracket = "abracket"

    // Embeds
    case AudioPlay = "embetter_audio_play"
    case VideoPlay = "embetter_video_play"

    func image(style: Style) -> UIImage? {
        switch style {
        case .Normal:   return normalImage
        case .White:    return whiteImage
        case .Selected: return selectedImage
        case .Disabled: return disabledImage
        case .Red:      return redImage
        }
    }

    var normalImage: UIImage! {
        switch self {
        case .ElloLogo,
            .AudioPlay,
            .VideoPlay,
            .BubbleTail,
            .NarrationPointer,
            .ValidationError,
            .ValidationOK:
            return SVGKImage(named: "\(self.rawValue).svg").UIImage
        default:
            return SVGKImage(named: "\(self.rawValue)_normal.svg").UIImage
        }
    }
    var selectedImage: UIImage! { return SVGKImage(named: "\(self.rawValue)_selected.svg").UIImage }
    var whiteImage: UIImage? { return SVGKImage(named: "\(self.rawValue)_white.svg").UIImage }
    var disabledImage: UIImage? {
        switch self {
        case .Repost, .AngleBracket:
            return SVGKImage(named: "\(self.rawValue)_disabled.svg").UIImage
        default:
            return nil
        }
    }
    var redImage: UIImage? { return SVGKImage(named: "\(self.rawValue)_red.svg").UIImage }
}

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
                return NSLocalizedString("Here's some tips on how to get new followers: use Discover to find people you're interested in, and to find or invite your contacts. When you see things you like you can comment, repost, mention people and love the posts that you most enjoy. ", comment: "Current user no followers results body.")
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
                return NSLocalizedString("Ello is way more rad when you're following lots of people.\n\nUse Discover to find people you're interested in, and to find or invite your contacts.\nYou can also use Search (upper right) to look for new and excellent people!", comment: "Current user No following results body.")
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

    public enum Starred {
        case Title

        var localized: String {
            switch self {
            case .Title:
                return NSLocalizedString("Starred", comment: "Starred title")
            }
        }
    }

    public enum Discover {
        case Title

        var localized: String {
            switch self {
            case .Title:
                return NSLocalizedString("Discover", comment: "Discover title")
            }
        }
    }

    public enum Profile {
        case Title

        var localized: String {
            switch self {
            case .Title:
                return NSLocalizedString("Profile", comment: "Profile Title")
            }
        }
    }

    public enum Post {
        case Edit
        case Delete

        var localized: String {
            switch self {
            case .Edit:
                return NSLocalizedString("Edit", comment: "Edit Post Button Title")
            case .Delete:
                return NSLocalizedString("Delete", comment: "Delete Post Button Title")
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

    public enum Startup {
        case SignInAfterJoinError

        var localized: String {
            switch self {
            case .SignInAfterJoinError:
                return NSLocalizedString("Your account has been created, but there was an error logging in, please try again", comment: "After successfully joining, there was an error signing in")
            }
        }
    }

    case LoggedOut
    case Cancel
    case OpenInSafari

    var localized: String {
        switch self {
        case .LoggedOut:
            return NSLocalizedString("You have been automatically logged out", comment: "Automatically logged out message")
        case .Cancel:
            return NSLocalizedString("Cancel", comment: "Cancel")
        case .OpenInSafari:
            return NSLocalizedString("Open in Safari", comment: "Open in Safari")
        }
    }

}
