//
//  ShareRegionProcessor.swift
//  Ello
//
//  Created by Sean on 2/11/16.
//  Copyright © 2016 Ello. All rights reserved.
//

import Foundation

public class ShareRegionProcessor {

    public init(){}

    public func prepContent(contentText: String, itemPreviews: [ExtensionItemPreview]) -> [PostEditingService.PostContentRegion] {
        var content: [PostEditingService.PostContentRegion] = []

        let cleanedText = contentText.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        if cleanedText.characters.count > 0 {
            let region = PostEditingService.PostContentRegion.Text(cleanedText)
            let exists = content.any {$0 == region}
            if !exists {
                content.append(region)
            }
        }
        for preview in itemPreviews {
            if let image = preview.image {
                let region = PostEditingService.PostContentRegion.ImageData(image, nil, nil)
                let exists = content.any {$0 == region}
                if !exists {
                    content.append(region)
                }
            }
            if let text = preview.text {
                let region = PostEditingService.PostContentRegion.Text(text)
                let exists = content.any {$0 == region}
                if !exists {
                    content.append(region)
                }
            }
        }

        return content
    }
}
