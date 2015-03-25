//
//  StreamNotificationCellSizeCalculator.swift
//  Ello
//
//  Created by Colin Gray on 2/17/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

class StreamNotificationCellSizeCalculator: NSObject, UIWebViewDelegate {

    typealias StreamTextCellSizeCalculated = () -> ()

    let webView:UIWebView
    let textView:ElloTextView
    let originalWidth:CGFloat
    var cellItems:[StreamCellItem] = []
    var completion:StreamTextCellSizeCalculated = {}

    let srcRegex:NSRegularExpression  = NSRegularExpression(
        pattern: "src=[\"']([^\"']*)[\"']",
        options: NSRegularExpressionOptions.CaseInsensitive,
        error: nil)!

    init(webView:UIWebView) {
        self.webView = webView
        originalWidth = self.webView.frame.size.width
        textView = ElloTextView(frame: CGRectZero.withWidth(originalWidth), textContainer: nil)
        super.init()
        self.webView.delegate = self
    }

    func processCells(cellItems:[StreamCellItem], withWidth width: CGFloat, completion:StreamTextCellSizeCalculated) {
        self.completion = completion
        self.cellItems = cellItems
        self.webView.frame = self.webView.frame.withWidth(width)
        loadNext()
    }

    private func loadNext() {
        if !self.cellItems.isEmpty {
            let notification = self.cellItems[0].jsonable as Notification

            if let textRegion = notification.textRegion {
                let content = textRegion.content
                // let strippedContent = self.stripImageSrc(content)
                let html = StreamTextCellHTML.postHTML(content)
                var f = self.webView.frame
                f.size.width = NotificationCell.Size.messageHtmlWidth(forCellWidth: originalWidth, hasImage: notification.hasImage())
                self.webView.frame = f
                self.webView.loadHTMLString(html, baseURL: NSURL(string: "/"))
            }
            else {
                calculateWithTextHeight(0)
            }
        }
        else {
            completion()
        }
    }

    func webViewDidFinishLoad(webView: UIWebView) {
        if let textHeight = self.webView.windowContentSize()?.height {
            calculateWithTextHeight(textHeight)
        }
        else {
            calculateWithTextHeight(0)
        }
    }

    private func calculateWithTextHeight(textHeight : CGFloat) {
        var cellItem = self.cellItems.removeAtIndex(0)
        let notification = cellItem.jsonable as Notification
        let imageHeight = NotificationCell.Size.imageHeight(imageRegion: notification.imageRegion)
        let titleWidth = NotificationCell.Size.messageHtmlWidth(forCellWidth: originalWidth, hasImage: notification.hasImage())
        textView.frame = textView.frame.withWidth(titleWidth)
        textView.attributedText = notification.attributedTitle
        textView.sizeToFit()
        let titleHeight = textView.frame.height

        var totalTextHeight = NotificationCell.Size.topBottomFixedHeight()
        totalTextHeight += titleHeight

        if textHeight > 0 {
            totalTextHeight += textHeight + NotificationCell.Size.innerTextMargin
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
        cellItem.calculatedWebHeight = textHeight
        loadNext()
    }

    private func stripImageSrc(html: String) -> String {
        // finds image tags, replaces them with data:image/png (inlines image data)
        let range = NSMakeRange(0, countElements(html))

        let strippedHtml :String = srcRegex.stringByReplacingMatchesInString(html,
            options: NSMatchingOptions.allZeros,
            range:range,
            withTemplate: "src=\"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAAAAAA6fptVAAAACklEQVR4nGNiAAAABgADNjd8qAAAAABJRU5ErkJggg==")

        return strippedHtml
    }

}
