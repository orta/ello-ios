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
    let originalWidth:CGFloat
    var cellItems:[StreamCellItem] = []
    var completion:StreamTextCellSizeCalculated = {}

    init(webView:UIWebView) {
        self.webView = webView
        self.originalWidth = self.webView.frame.size.width
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
            let notification = self.cellItems[0].jsonable as Notification

            if let textElement = notification.textRegion {
                var f = self.webView.frame
                f.size.width = NotificationCell.messageHtmlWidth(forCellWidth: originalWidth, hasImage: notification.hasImage())
                self.webView.frame = f
                self.webView.loadHTMLString(StreamTextCellHTML.postHTML(textElement.content), baseURL: NSURL(string: "/"))
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
        if let jsResult = self.webView.stringByEvaluatingJavaScriptFromString("window.contentHeight()") {
            let textHeight = CGFloat((jsResult as NSString).doubleValue)
            calculateWithTextHeight(textHeight)
        }
        else {
            calculateWithTextHeight(0)
        }
    }

    func calculateWithTextHeight(textHeight : CGFloat) {
        var cellItem = self.cellItems.removeAtIndex(0)
        let notification = cellItem.jsonable as Notification
        let imageHeight = NotificationCell.imageHeight(imageRegion: notification.imageRegion)
        var margins = NotificationCell.topBottomMargins()

        var height : CGFloat
        if textHeight > imageHeight {
            height = textHeight
        }
        else {
            height = imageHeight
        }

        cellItem.multiColumnCellHeight = height + margins
        cellItem.oneColumnCellHeight = height + margins
        loadNext()
    }

}
