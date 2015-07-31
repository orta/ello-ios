//
//  ProfileHeaderCellSizeCalculator.swift
//  Ello
//
//  Created by Ryan Boyajian on 3/24/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

public class ProfileHeaderCellSizeCalculator: NSObject {

    let webView: UIWebView
    var maxWidth: CGFloat = 0.0
    public var cellItems: [StreamCellItem] = []
    public var completion: ElloEmptyCompletion = {}
    let ratio:CGFloat = 16.0/9.0

    required public init(webView wv: UIWebView) {
        self.webView = wv
        super.init()
        webView.delegate = self
    }

    public func processCells(cellItems: [StreamCellItem], withWidth width: CGFloat, completion: ElloEmptyCompletion) {
        self.cellItems = cellItems
        self.completion = completion
        self.maxWidth = width
        // -30 for the padding on the webview
        self.webView.frame = self.webView.frame.withWidth(self.maxWidth - (StreamTextCellPresenter.postMargin * 2))
        loadNext()
    }

    private func loadNext() {
        if let item = cellItems.safeValue(0),
            let user = item.jsonable as? User
        {
            let html = StreamTextCellHTML.postHTML(user.headerHTMLContent)
            // needs to use the same width as the post text region
            webView.loadHTMLString(html, baseURL: NSURL(string: "/"))
        }
        else {
            completion()
        }
    }

    private func assignCellHeight(hv: CGFloat) {
        if let cellItem = cellItems.safeValue(0) {
            self.cellItems.removeAtIndex(0)
            var height: CGFloat = maxWidth / ratio // cover image size
            height += 193.0 // top of webview
            // add web view height and bottom padding
            if hv > 0.0 {
                height += hv
            }
            cellItem.calculatedOneColumnCellHeight = height
            cellItem.calculatedMultiColumnCellHeight = height
        }
        loadNext()
    }
}

extension ProfileHeaderCellSizeCalculator: UIWebViewDelegate {

    public func webViewDidFinishLoad(webView: UIWebView) {
        let jsResult = webView.stringByEvaluatingJavaScriptFromString("window.contentHeight()") ?? "0.0"
        assignCellHeight(CGFloat((jsResult as NSString).doubleValue))
    }

}
