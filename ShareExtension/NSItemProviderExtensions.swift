//
//  NSItemProviderExtensions.swift
//  Ello
//
//  Created by Sean on 2/5/16.
//  Copyright © 2016 Ello. All rights reserved.
//

import Foundation
import MobileCoreServices

extension NSItemProvider {

    func isURL() -> Bool {
        return self.hasItemConformingToTypeIdentifier(String(kUTTypeURL))
    }
    func isImage() -> Bool {
        return self.hasItemConformingToTypeIdentifier(String(kUTTypeImage))
    }

    func isText() -> Bool {
        return self.hasItemConformingToTypeIdentifier(String(kUTTypeText))
    }

    func isGif() -> Bool {
        return self.hasItemConformingToTypeIdentifier(String(kUTTypeGIF))
    }

    func loadText(options: [NSObject : AnyObject]?, completion: NSItemProviderCompletionHandler?) {
        self.loadItemForTypeIdentifier(String(kUTTypeText), options: options, completionHandler: completion)
    }

    func loadURL(options: [NSObject : AnyObject]?, completion: NSItemProviderCompletionHandler?) {
        self.loadItemForTypeIdentifier(String(kUTTypeURL), options: options, completionHandler: completion)
    }

    func loadPreview(options: [NSObject : AnyObject]!, completion: NSItemProviderCompletionHandler!) {
        self.loadPreviewImageWithOptions(options, completionHandler: completion)
    }

    func loadImage(options: [NSObject : AnyObject]!, completion: NSItemProviderCompletionHandler!) {
        self.loadItemForTypeIdentifier(String(kUTTypeImage), options: options, completionHandler: completion)
    }
}
