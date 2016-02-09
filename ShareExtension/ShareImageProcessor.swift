//
//  ShareImageProcessor.swift
//  Ello
//
//  Created by Sean on 2/8/16.
//  Copyright © 2016 Ello. All rights reserved.
//

import Foundation
import UIKit

typealias ExtensionItemProcessor = ExtensionItemPreview? -> Void

public struct ShareImageProcessor {

    let existsFilter: (ExtensionItemPreview) -> Bool

    public func previewFromExtensionItem(extensionItem: NSExtensionItem, callback: [ExtensionItemPreview] -> Void) {
        var previews: [ExtensionItemPreview] = []
        processAttachments(0, attachments: extensionItem.attachments as? [NSItemProvider] , previews: &previews, callback: callback)
    }
}

// MARK: Private

private extension ShareImageProcessor {

    func processAttachments(
        index: Int,
        attachments: [NSItemProvider]?,
        inout previews: [ExtensionItemPreview],
        callback: [ExtensionItemPreview] -> Void)
    {
        if let attachment = attachments?.safeValue(index) {
            processAttachment(attachment) { preview in
                if let preview = preview {
                    let exists = self.existsFilter(preview)
                    if !exists {
                        previews.append(preview)
                    }
                }
                self.processAttachments(
                    index + 1,
                    attachments: attachments,
                    previews: &previews,
                    callback: callback
                )
            }
        }
        else {
            callback(previews)
        }
    }

    func processAttachment( attachment: NSItemProvider, callback: ExtensionItemProcessor)
    {
        if attachment.isText() {
            self.processText(attachment, callback: callback)
        }
        else if attachment.isURL() {
            self.processURL(attachment, callback: callback)
        }
        else if attachment.isImage() {
            self.processImage(attachment, callback: callback)
        }
    }

    func processText(attachment: NSItemProvider, callback: ExtensionItemProcessor) {
        attachment.loadText(nil) {
            (item, error) in
            var preview: ExtensionItemPreview?
            if let item = item as? String {
                preview = ExtensionItemPreview(image: nil, imagePath: nil, text: item)
            }
            callback(preview)
        }
    }

    func processURL(attachment: NSItemProvider, callback: ExtensionItemProcessor) {
        var link: String?
        var preview: UIImage?

        let urlAndPreviewLoaded = after(2) {
            let item = ExtensionItemPreview(image: preview, imagePath: nil, text: link)
            callback(item)
        }

        attachment.loadURL(nil) {
            (item, error) in
            if let item = item as? NSURL {
                link = item.absoluteString
            }
            urlAndPreviewLoaded()
        }

        attachment.loadPreview(nil) {
            (image, error) in
            preview = image as? UIImage
            urlAndPreviewLoaded()
        }
    }

    func processImage(attachment: NSItemProvider, callback: ExtensionItemProcessor) {
        attachment.loadImage(nil) {
            (imageURL, error) in
            if let imagePath = imageURL as? NSURL,
                let data = NSData(contentsOfURL: imagePath),
                let image = UIImage(data: data)
            {
                image.copyWithCorrectOrientationAndSize() { image in
                    let item = ExtensionItemPreview(image: image, imagePath: nil, text: nil)
                    callback(item)
                }
            }
            else {
                callback(nil)
            }
        }
    }
}
