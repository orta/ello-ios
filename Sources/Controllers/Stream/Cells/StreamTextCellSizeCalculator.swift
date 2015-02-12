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

    let webView:UIWebView
    var cellItems:[StreamCellItem] = []
    var completion:StreamTextCellSizeCalculated = {}

    init(webView:UIWebView) {
        self.webView = webView
        super.init()
        self.webView.delegate = self
    }

    func processCells(cellItems:[StreamCellItem], completion:StreamTextCellSizeCalculated) {
        self.completion = completion
        self.cellItems = cellItems
        loadNext()
    }

    private func loadNext() {
        if !self.cellItems.isEmpty {
            let textElement = self.cellItems[0].data as? TextRegion

            if let textElement = textElement {
                self.webView.loadHTMLString(StreamTextCellHTML.postHTML(textElement.content), baseURL: NSURL(string: "/"))
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