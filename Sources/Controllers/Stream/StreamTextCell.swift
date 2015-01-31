//
//  StreamTextCell.swift
//  Ello
//
//  Created by Sean Dougherty on 11/22/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import WebKit
import Foundation

enum RequestType {
    case Post
    case Profile
    case External

    var regexPattern: String {
        switch self {
        case .Post: return "ello(-staging.herokuapp)?\\.co(m)?\\/.+\\/post\\/[^\\/]+\\/?$"
        case .Profile: return "ello(-staging.herokuapp)?\\.co(m)?\\/[^\\/]+\\/?$"
        case .External: return "https?:\\/\\"
        }
    }

    static func match(url: String) -> RequestType {
        for type in self.all {
            if let match = url.rangeOfString(type.regexPattern, options: .RegularExpressionSearch) {
                return type
            }
        }
        return self.External
    }

    // Order matters: [MostSpecific, MostGeneric]
    static let all = [Post, Profile, External]
}

class StreamTextCell: UICollectionViewCell, UIWebViewDelegate {


    @IBOutlet weak var webView:UIWebView!
    @IBOutlet weak var leadingConstraint:NSLayoutConstraint!

    var calculatedHeight:CGFloat = 0.0
    let jsCommandProtocol = "ello://"
    let jsCommandPageReady = "ello://page-ready:"

    override func layoutSubviews() {
        self.webView.frame = self.bounds
        super.layoutSubviews()
        webView.scrollView.scrollEnabled = false
    }

    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
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
            switch RequestType.match(requestURL) {
            case .External: postNotification(externalWebNotification, requestURL)
            case .Profile: println("Profile link clicked: \(requestURL)")
            case .Post: println("Post link clicked: \(requestURL)")
            }
            return false
        }
        return true
    }

    func webViewDidFinishLoad(webView: UIWebView) {
        UIView.animateWithDuration(0.15, animations: {
            self.contentView.alpha = 1.0
        })
    }
}
