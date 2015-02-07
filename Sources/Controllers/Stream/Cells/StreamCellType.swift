//
//  StreamCellType.swift
//  Ello
//
//  Created by Sean on 2/7/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

enum StreamCellType {
    case CommentHeader
    case Header
    case Footer
    case Image
    case Text
    case Comment
    case Unknown

    var name: String {
        switch self {
        case CommentHeader: return "StreamCommentHeaderCell"
        case Header: return "StreamHeaderCell"
        case Footer: return "StreamFooterCell"
        case Image: return "StreamImageCell"
        case Text: return "StreamTextCell"
        case Comment: return "StreamCommentCell"
        case Unknown: return "StreamUnknownCell"
        }
    }
}