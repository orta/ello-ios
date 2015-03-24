//
//  StreamTextCellSizeCalculator.swift
//  Ello
//
//  Created by Sean Dougherty on 12/15/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Foundation

class StreamTextCellSizeCalculator: NSObject, UIWebViewDelegate {

    typealias StreamTextCellSizeCalculated = () -> ()

    let webView: UIWebView
    var maxWidth: CGFloat
    var cellItems: [StreamCellItem] = []
    var completion: StreamTextCellSizeCalculated = {}

    init(webView:UIWebView) {
        self.webView = webView
        self.maxWidth = 0
        super.init()
        self.webView.delegate = self
    }

    func processCells(cellItems:[StreamCellItem], withWidth width: CGFloat, completion:StreamTextCellSizeCalculated) {
        self.completion = completion
        self.cellItems = cellItems
        self.maxWidth = width
        loadNext()
    }

    private func loadNext() {
        if !self.cellItems.isEmpty {
            let item = self.cellItems[0]
            if let comment = item.jsonable as? Comment {
                self.webView.frame = self.webView.frame.withWidth(maxWidth - StreamTextCellPresenter.commentMargin)
            }
            else {
                self.webView.frame = self.webView.frame.withWidth(maxWidth)
            }
            let textElement = item.data as? TextRegion

            if let textElement = textElement {
                let content = textElement.content
                let html = StreamTextCellHTML.postHTML(content)
                // needs to use the same width as the post text region
                self.webView.loadHTMLString(html, baseURL: NSURL(string: "/"))
            }
            else {
                self.cellItems.removeAtIndex(0)
                loadNext()
            }
        }
        else {
            completion()
        }
    }

    func webViewDidFinishLoad(webView: UIWebView) {
        var cellItem = self.cellItems.removeAtIndex(0)
        if let jsResult = self.webView.stringByEvaluatingJavaScriptFromString("window.contentHeight()") {
            let height = CGFloat((jsResult as NSString).doubleValue)
            cellItem.multiColumnCellHeight = height
            cellItem.oneColumnCellHeight = height
        }
        loadNext()
    }
}
