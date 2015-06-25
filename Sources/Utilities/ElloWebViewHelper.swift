//
//  ElloWebViewHelper.swift
//  Ello
//
//  Created by Colin Gray on 2/20/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public struct ElloWebViewHelper {
    static let jsCommandProtocol = "ello://"

    static func handleRequest(request: NSURLRequest, webLinkDelegate: WebLinkDelegate?, fromWebView: Bool = false) -> Bool {
        let requestURL = request.URLString
        if requestURL.hasPrefix(jsCommandProtocol) {
            return false
        }
        else if requestURL.rangeOfString("(https?:\\/\\/|mailto:)", options: .RegularExpressionSearch) != nil {
            let (type, data) = ElloURI.match(requestURL)
            switch type {
            case .Email:
                if let url = NSURL(string: requestURL) {
                    UIApplication.sharedApplication().openURL(url)
                }
                return false
            case .Downloads, .External, .Wallpapers, .WTF:
                if fromWebView == true { return true }
                webLinkDelegate?.webLinkTapped(type, data: data)
                return false
            default:
                webLinkDelegate?.webLinkTapped(type, data: data)
                return false
            }
        }
        return true
    }
}
