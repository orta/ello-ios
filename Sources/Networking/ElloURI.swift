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
    case Discover = "discover"
    case Downloads = "downloads"
    case Email = "email"
    case External = "external"
    case Friends = "friends"
    case Internal = "internal"
    case Noise = "noise"
    case Notifications = "notifications"
    case Post = "post"
    case Profile = "profile"
    case Search = "search"
    case Settings = "settings"
    case WTF = "wtf"
    case Wallpapers = "wallpapers"

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
    static let emailRegex = "(.+)@(.+)\\.([a-z]{2,})"
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
        case .Email: return ElloURI.emailRegex
        case .Wallpapers: return "wallpapers\\.\(ElloURI.fuzzyDomain)"
        case .Post: return "\(ElloURI.userPathRegex)\\/post\\/[^\\/]+\\/?$"
        case .WTF: return "\(ElloURI.fuzzyDomain)/(wtf$|wtf\\/.*$)"
        case .Discover: return "\(ElloURI.fuzzyDomain)/discover"
        case .Downloads: return "\(ElloURI.fuzzyDomain)/downloads"
        case .Friends: return "\(ElloURI.fuzzyDomain)/friends"
        case .Noise: return "\(ElloURI.fuzzyDomain)/noise"
        case .Notifications: return "\(ElloURI.fuzzyDomain)/notifications"
        case .Search: return "\(ElloURI.fuzzyDomain)/search"
        case .Settings: return "\(ElloURI.fuzzyDomain)/settings"
        case .Profile: return "\(ElloURI.userPathRegex)\\/?$"
        case .Internal: return "\(ElloURI.fuzzyDomain)"
        case .External: return "https?:\\/\\/.{3,}"
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
    static let all = [Email, Wallpapers, Post, WTF, Discover, Downloads, Friends, Noise, Notifications, Search, Settings, Profile, Internal, External]
}
