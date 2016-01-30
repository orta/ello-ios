//
//  ShareAPI.swift
//  Ello
//
//  Created by Sean on 1/29/16.
//  Copyright © 2016 Ello. All rights reserved.
//

import Foundation
import Moya
import Alamofire

public enum ShareAPI {
    case AnonymousCredentials
    case Auth(email: String, password: String)
    case ReAuth(token: String)
    case CreatePost(body: [String: AnyObject])

    public static let apiVersion = "v2"
}

extension ShareAPI: Moya.TargetType {
    public var baseURL: NSURL { return NSURL(string: ElloURI.baseURL)! }


    public var parameters: [String: AnyObject]? {
        switch self {
        case .AnonymousCredentials:
            return [
                "client_id": APIKeys.sharedKeys.key ?? "",
                "client_secret": APIKeys.sharedKeys.secret ?? "",
                "grant_type": "client_credentials"
            ]
        case let .Auth(email, password):
            return [
                "client_id": APIKeys.sharedKeys.key ?? "",
                "client_secret": APIKeys.sharedKeys.secret ?? "",
                "email": email,
                "password":  password,
                "grant_type": "password"
            ]
        case let .ReAuth(refreshToken):
            return [
                "client_id": APIKeys.sharedKeys.key ?? "",
                "client_secret": APIKeys.sharedKeys.secret ?? "",
                "grant_type": "refresh_token",
                "refresh_token": refreshToken
            ]
        case let .CreatePost(body):
            return body
        }

    }

    public var method: Moya.Method {
        switch self {
        case .AnonymousCredentials,
        .Auth,
        .CreatePost,
        .ReAuth:
            return .POST
        }
    }

    public var path: String {
        switch self {
        case .AnonymousCredentials,
        .Auth,
        .ReAuth:
            return "/api/oauth/token"
        case .CreatePost:
            return "/api/\(ShareAPI.apiVersion)/posts"
        }
    }

    public var sampleData: NSData {
        return NSData()
    }
}

