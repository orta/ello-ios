//
//  ElloURI.swift
//  Ello
//
//  Created by Ryan Boyajian on 2/2/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation
import Keys

public enum ElloURI: String {
    // matching stream or page in app
    case Discover = "discover"
    case Enter = "enter"
    case Friends = "friends"
    case Noise = "noise"
    case Notifications = "notifications"
    case Post = "\\/post\\/[^\\/]+\\/?$"
    case Profile = "\\/?$"
    case Search = "search"
    case Settings = "settings"
    // other ello pages
    case BetaPublicProfiles = "beta-public-profiles"
    case Downloads = "downloads"
    case Exit = "exit"
    case ForgotMyPassword = "forgot-my-password"
    case Internal = "internal"
    case Manifesto = "manifesto"
    case RequestInvite = "request-an-invite"
    case RequestInvitation = "request-an-invitation"
    case Subdomain = "\\/\\/.+(?<!w{3})\\."
    case WhoMadeThis = "who-made-this"
    case WTF = "(wtf$|wtf\\/.*$)"
    // more specific
    case Email = "(.+)@(.+)\\.([a-z]{2,})"
    case External = "https?:\\/\\/.{3,}"

    public var loadsInWebViewFromWebView: Bool {
        switch self {
        case .Discover, .Email, .Enter, .Friends, .Internal, .Noise, .Notifications, .Post, .Profile, .Search, .Settings: return false
        default: return true
        }

    }

    // get the proper domain
    private static var _httpProtocol: String?
    public static var httpProtocol: String {
        get {
            return ElloURI._httpProtocol ?? ElloKeys().httpProtocol()
        }
        set {
            if AppSetup.sharedState.isTesting {
                ElloURI._httpProtocol = newValue
            }
        }
    }
    private static var _domain: String?
    public static var domain: String {
        get {
        return ElloURI._domain ?? ElloKeys().domain()
        }
        set {
            if AppSetup.sharedState.isTesting {
                ElloURI._domain = newValue
            }
        }
    }
    public static var baseURL: String { return "\(ElloURI.httpProtocol)://\(ElloURI.domain)" }

    // this is taken directly from app/models/user.rb
    static let usernameRegex = "[\\w\\-]+"
    static let fuzzyDomain: String = "((w{3}\\.)?ello\\.co|ello-staging\\d?\\.herokuapp\\.com)"
    static var userPathRegex: String { return "\(ElloURI.fuzzyDomain)\\/\(ElloURI.usernameRegex)\\??.*" }

    public static func match(url: String) -> (type: ElloURI, data: String) {
        for type in self.all {
            if let match = url.rangeOfString(type.regexPattern, options: .RegularExpressionSearch) {
                return (type, type.data(url))
            }
        }
        return (self.External, self.External.data(url))
    }

    private var regexPattern: String {
        switch self {
        case .Email, .External: return rawValue
        case .Internal: return "\(ElloURI.fuzzyDomain)"
        case .Post: return "\(ElloURI.userPathRegex)\(rawValue)"
        case .Profile: return "\(ElloURI.userPathRegex)\(rawValue)"
        case .Subdomain: return "\(rawValue)\(ElloURI.fuzzyDomain)"
        default: return "\(ElloURI.fuzzyDomain)\\/\(rawValue)"
        }
    }

    private func data(url: String) -> String {
        switch self {
        case .Post, .Profile:
            var urlArr = split(url) { $0 == "/" }
            var last = urlArr.last ?? url
            var lastArr = split(last) { $0 == "?" }
            return lastArr.first ?? url
        default: return url
        }
    }

    // Order matters: [MostSpecific, MostGeneric]
    static let all = [
        Email,
        Subdomain,
        Post,
        WTF,
        // generic / pages
        BetaPublicProfiles,
        Discover,
        Downloads,
        Enter,
        Exit,
        ForgotMyPassword,
        Friends,
        Manifesto,
        Noise,
        Notifications,
        RequestInvite,
        RequestInvitation,
        Search,
        Settings,
        WhoMadeThis,
        // profile specific
        Profile,
        // other ello urls
        Internal,
        // anything else
        External
    ]
}
