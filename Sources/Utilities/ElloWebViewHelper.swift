//
//  ElloWebViewHelper.swift
//  Ello
//
//  Created by Colin Gray on 2/20/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

struct ElloWebViewHelper {
    static let jsCommandProtocol = "ello://"
    static let jsCommandPageReady = "ello://page-ready:"

    static func handleRequest(request: NSURLRequest, webLinkDelegate: WebLinkDelegate?) -> Bool {
        let requestURL = request.URLString
        if requestURL.hasPrefix(jsCommandProtocol) {
//            if requestURL.hasPrefix(jsCommandPageReady) {
//                let heightAsString:String = requestURL.stringByReplacingOccurrencesOfString(jsCommandPageReady, withString: "")
//
//                let height = CGFloat((heightAsString as NSString).doubleValue)
//                    calculatedHeight = height
//                    NSNotificationCenter.defaultCenter().postNotificationName("UpdateHeightNotification", object: self)
//                UIView.animateWithDuration(0.15, animations: {
//                    self.contentView.alpha = 1.0
//                })
//            }
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