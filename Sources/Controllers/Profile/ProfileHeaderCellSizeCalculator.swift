//
//  ProfileHeaderCellSizeCalculator.swift
//  Ello
//
//  Created by Ryan Boyajian on 3/24/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

class ProfileHeaderCellSizeCalculator: NSObject {

    let webView: UIWebView
    var cellItems: [StreamCellItem] = []
    var completion: ElloEmptyCompletion = {}
    let ratio:CGFloat = 16.0/9.0

    required init(webView wv: UIWebView) {
        webView = wv
        super.init()
        webView.delegate = self
    }

    func processCells(cellItems: [StreamCellItem], withWidth width: CGFloat, completion: ElloEmptyCompletion) {
        self.cellItems = cellItems
        self.completion = completion
        self.webView.frame = self.webView.frame.withWidth(width)
        loadNext()
    }

    private func loadNext() {
        if !cellItems.isEmpty {
            let user = cellItems[0].jsonable as! User
            if user.formattedShortBio == "" {
                setHeight(0.0)
            }
            else {
                webView.loadHTMLString(StreamTextCellHTML.postHTML(user.formattedShortBio), baseURL: NSURL(string: "/"))
            }
        }
        else {
            completion()
        }
    }

    private func setHeight(hv: CGFloat) {
        var cellItem = self.cellItems.removeAtIndex(0)
        var height: CGFloat = hv
        // add height to top of name label
        if let user = cellItem.jsonable as? User {
            height += user.name == "" ? 130.0 : 142.0
        }
        // add bottom padding of name label
        height += hv == 0 ? 0 : 15
        // add area for cover image
        height += webView.frame.width / ratio
        cellItem.multiColumnCellHeight = height
        cellItem.oneColumnCellHeight = height
        loadNext()
    }
}

extension ProfileHeaderCellSizeCalculator: UIWebViewDelegate {

    func webViewDidFinishLoad(webView: UIWebView) {
        let jsResult = webView.stringByEvaluatingJavaScriptFromString("window.contentHeight()") ?? "0.0"
        setHeight(CGFloat((jsResult as NSString).doubleValue))
    }

}
