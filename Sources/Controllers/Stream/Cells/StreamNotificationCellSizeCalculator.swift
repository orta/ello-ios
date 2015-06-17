//
//  StreamNotificationCellSizeCalculator.swift
//  Ello
//
//  Created by Colin Gray on 2/17/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//


private let textViewForSizing = ElloTextView(frame: CGRectZero, textContainer: nil)

public class StreamNotificationCellSizeCalculator: NSObject, UIWebViewDelegate {

    public typealias StreamTextCellSizeCalculated = () -> Void

    let webView:UIWebView
    var originalWidth:CGFloat
    public var cellItems:[StreamCellItem] = []
    public var completion:StreamTextCellSizeCalculated = {}

    let srcRegex:NSRegularExpression  = NSRegularExpression(
        pattern: "src=[\"']([^\"']*)[\"']",
        options: NSRegularExpressionOptions.CaseInsensitive,
        error: nil)!

    public init(webView:UIWebView) {
        self.webView = webView
        originalWidth = self.webView.frame.size.width
        super.init()
        self.webView.delegate = self
    }

    public func processCells(cellItems:[StreamCellItem], withWidth width: CGFloat, completion:StreamTextCellSizeCalculated) {
        self.completion = completion
        self.cellItems = cellItems
        self.originalWidth = width
        self.webView.frame = self.webView.frame.withWidth(width)
        loadNext()
    }

    private func loadNext() {
        if let activity = self.cellItems.safeValue(0) {
            if let notification = activity.jsonable as? Notification,
                let textRegion = notification.textRegion
            {
                let content = textRegion.content
                let strippedContent = self.stripImageSrc(content)
                let html = StreamTextCellHTML.postHTML(strippedContent)
                var f = self.webView.frame
                f.size.width = NotificationCell.Size.messageHtmlWidth(forCellWidth: originalWidth, hasImage: notification.hasImage())
                self.webView.frame = f
                self.webView.loadHTMLString(html, baseURL: NSURL(string: "/"))
            }
            else {
                assignCellHeight(0)
            }
        }
        else {
            dispatch_async(dispatch_get_main_queue(), completion)
        }
    }

    public func webViewDidFinishLoad(webView: UIWebView) {
        if let webContentHeight = self.webView.windowContentSize()?.height {
            assignCellHeight(webContentHeight)
        }
        else {
            assignCellHeight(0)
        }
    }

    private func assignCellHeight(webContentHeight : CGFloat) {
        if let cellItem = self.cellItems.safeValue(0) {
            self.cellItems.removeAtIndex(0)
            StreamNotificationCellSizeCalculator.assignTotalHeight(webContentHeight, cellItem: cellItem, cellWidth: originalWidth)
        }
        loadNext()
    }

    class func assignTotalHeight(webContentHeight: CGFloat, cellItem: StreamCellItem, cellWidth: CGFloat) {
        let notification = cellItem.jsonable as! Notification
        let imageHeight = NotificationCell.Size.imageHeight(imageRegion: notification.imageRegion)
        let titleWidth = NotificationCell.Size.messageHtmlWidth(forCellWidth: cellWidth, hasImage: notification.hasImage())
        textViewForSizing.frame = textViewForSizing.frame.withWidth(titleWidth)
        textViewForSizing.attributedText = notification.attributedTitle
        textViewForSizing.sizeToFit()
        let titleHeight = textViewForSizing.frame.height

        var totalTextHeight = NotificationCell.Size.topBottomFixedHeight()
        totalTextHeight += titleHeight

        if webContentHeight > 0 {
            totalTextHeight += webContentHeight + NotificationCell.Size.innerTextMargin
        }

        var height : CGFloat
        if totalTextHeight > imageHeight {
            height = totalTextHeight
        }
        else {
            height = imageHeight
        }

        var margins = NotificationCell.Size.topBottomMargins
        height += margins
        cellItem.multiColumnCellHeight = height
        cellItem.oneColumnCellHeight = height
        cellItem.calculatedWebHeight = webContentHeight
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
