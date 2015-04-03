//
//  StreamTextCellSizeCalculator.swift
//  Ello
//
//  Created by Sean Dougherty on 12/15/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Foundation

public class StreamTextCellSizeCalculator: NSObject, UIWebViewDelegate {
    public typealias StreamTextCellSizeCalculated = () -> ()

    let webView: UIWebView
    var maxWidth: CGFloat
    public var cellItems: [StreamCellItem] = []
    public var completion: StreamTextCellSizeCalculated = {}

    let srcRegex:NSRegularExpression  = NSRegularExpression(
        pattern: "src=[\"']([^\"']*)[\"']",
        options: NSRegularExpressionOptions.CaseInsensitive,
        error: nil)!

    public init(webView:UIWebView) {
        self.webView = webView
        self.maxWidth = 0
        super.init()
        self.webView.delegate = self
    }

    public func processCells(cellItems:[StreamCellItem], withWidth width: CGFloat, completion:StreamTextCellSizeCalculated) {
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
                let strippedContent = self.stripImageSrc(content)
                let html = StreamTextCellHTML.postHTML(strippedContent)
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

    public func webViewDidFinishLoad(webView: UIWebView) {
        var cellItem = self.cellItems.removeAtIndex(0)
        if let textHeight = self.webView.windowContentSize()?.height {
            cellItem.multiColumnCellHeight = textHeight
            cellItem.oneColumnCellHeight = textHeight
            cellItem.calculatedWebHeight = textHeight
        }
        loadNext()
    }

    private func stripImageSrc(html: String) -> String {
        // finds image tags, replaces them with data:image/png (inlines image data)
        let range = NSMakeRange(0, count(html))

        let strippedHtml :String = srcRegex.stringByReplacingMatchesInString(html,
            options: NSMatchingOptions.allZeros,
            range:range,
            withTemplate: "src=\"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAAAAAA6fptVAAAACklEQVR4nGNiAAAABgADNjd8qAAAAABJRU5ErkJggg==")

        return strippedHtml
    }

}
