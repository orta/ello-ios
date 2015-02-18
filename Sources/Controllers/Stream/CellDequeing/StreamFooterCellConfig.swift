//
//  StreamFooterCellConfig.swift
//  Ello
//
//  Created by Sean on 2/18/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

extension StreamFooterCell: ConfigurableCell {

    func configure(streamCellItem:StreamCellItem, streamKind: StreamKind, indexPath: NSIndexPath) {
        if let post = streamCellItem.jsonable as? Post {
            self.comments = post.commentsCount?.localizedStringFromNumber()

            if streamKind.isDetail {
                self.commentsOpened = true
            }

            if streamKind.isGridLayout {
                self.views = ""
                self.reposts = ""
            }
            else {
                self.views = post.viewsCount?.localizedStringFromNumber()
                self.reposts = post.repostsCount?.localizedStringFromNumber()
            }
            self.streamKind = streamKind
        }
    }
}