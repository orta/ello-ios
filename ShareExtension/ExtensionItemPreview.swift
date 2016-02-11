//
//  ExtensionItemPreview.swift
//  Ello
//
//  Created by Sean on 2/5/16.
//  Copyright © 2016 Ello. All rights reserved.
//

import UIKit

public struct ExtensionItemPreview {
    public let image: UIImage?
    public let imagePath: NSURL?
    public let text: String?

    public init(image: UIImage?, imagePath: NSURL?, text: String?) {
        self.image = image
        self.imagePath = imagePath
        self.text = text
    }

    public var description: String {
        return "image: \(self.image), imagePath: \(self.imagePath) text: \(self.text)"
    }
}

public func ==(lhs: ExtensionItemPreview, rhs: ExtensionItemPreview) -> Bool {
    return lhs.image == rhs.image && lhs.imagePath == rhs.imagePath && lhs.text == rhs.text
}

