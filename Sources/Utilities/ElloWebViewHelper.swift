//
//  ElloWebViewHelper.swift
//  Ello
//
//  Created by Colin Gray on 2/20/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public struct ElloWebViewHelper {
    static let jsCommandProtocol = "ello://"

    static func handleRequest(request: NSURLRequest, webLinkDelegate: WebLinkDelegate?) -> Bool {
        let requestURL = request.URLString
        if requestURL.hasPrefix(jsCommandProtocol) {
            return false
        }
        else if requestURL.hasPrefix("http://") || requestURL.hasPrefix("https://") {
            let (type, data) = ElloURI.match(requestURL)
            webLinkDelegate?.webLinkTapped(type, data: data)
            return false
        }
        return true
    }

}
