//
//  StreamTextCellConfig.swift
//  Ello
//
//  Created by Sean on 2/18/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit

extension StreamTextCell: ConfigurableCell {

    func configure(streamCellItem:StreamCellItem, streamKind: StreamKind, indexPath: NSIndexPath) {
        self.contentView.alpha = 0.0
        if let textData = streamCellItem.data as TextRegion? {
            self.webView.loadHTMLString(StreamTextCellHTML.postHTML(textData.content), baseURL: NSURL(string: "/"))
        }

        if let comment = streamCellItem.jsonable as? Comment {
            self.leadingConstraint.constant = 58.0
        }
        else {
            self.leadingConstraint.constant = 0.0
        }
    }

}