//
//  NSURL.swift
//  Ello
//
//  Created by Sean on 5/19/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

extension NSURL {
    var hasGifExtension: Bool {
        return pathExtension?.lowercaseString == "gif"
    }
}

public extension NSURL {
    var absoluteStringWithoutProtocol: String {
        return (host ?? "") + (path ?? "")
    }
}
