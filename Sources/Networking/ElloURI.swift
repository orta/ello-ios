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
    case Post = "post"
    case WTF = "wtf"
    case Profile = "profile"
    case Settings = "settings"
    case Friends = "friends"
    case Noise = "noise"
    case Notifications = "notifications"
    case Search = "search"
    case Discover = "discover"
    case Internal = "internal"
    case External = "external"

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
    static var userPathRegex: String { return "\(ElloURI.fuzzyDomain)\\/\(ElloURI.usernameRegex)" }



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
        case .Post: return "\(ElloURI.userPathRegex)\\/post\\/[^\\/]+\\/?$"
        case .WTF: return "https?:\\/\\/\(ElloURI.fuzzyDomain)/wtf"
        case .Settings: return "\(ElloURI.fuzzyDomain)/settings"
        case .Friends: return "\(ElloURI.fuzzyDomain)/friends"
        case .Noise: return "\(ElloURI.fuzzyDomain)/noise"
        case .Notifications: return "\(ElloURI.fuzzyDomain)/notifications"
        case .Search: return "\(ElloURI.fuzzyDomain)/search"
        case .Discover: return "\(ElloURI.fuzzyDomain)/discover"
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
    static let all = [Post, WTF, Settings, Friends, Noise, Notifications, Search, Discover, Profile, Internal, External]
}
