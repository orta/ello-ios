//
//  StreamImageCellConfig.swift
//  Ello
//
//  Created by Sean on 2/18/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

extension StreamImageCell: ConfigurableCell {

    func configure(streamCellItem:StreamCellItem, streamKind: StreamKind, indexPath: NSIndexPath) {
        if let photoData = streamCellItem.data as ImageRegion? {
            if let photoURL = photoData.asset?.hdpi?.url? {
                self.serverProvidedAspectRatio = StreamCellItemParser.aspectRatioForImageBlock(photoData)
                self.setImageURL(photoURL)
            }
            else if let photoURL = photoData.url? {
                self.setImageURL(photoURL)
            }
        }
    }
}