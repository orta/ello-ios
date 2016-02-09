//
//  ExtensionItemPreview.swift
//  Ello
//
//  Created by Sean on 2/5/16.
//  Copyright © 2016 Ello. All rights reserved.
//

import UIKit

public struct ExtensionItemPreview {
    let image: UIImage?
    let imagePath: NSURL?
    let text: String?

    public var description: String {
        return "image: \(self.image), imagePath: \(self.imagePath) text: \(self.text)"
    }
}

public func ==(lhs: ExtensionItemPreview, rhs: ExtensionItemPreview) -> Bool {
    return lhs.image == rhs.image && lhs.imagePath == rhs.imagePath && lhs.text == rhs.text
}

