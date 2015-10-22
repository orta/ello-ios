//
//  FakeImageManager.swift
//  Ello
//
//  Created by Sean on 4/28/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import PINRemoteImage 

public class FakeImageManager: PINRemoteImageManager {

    public var downloads = [NSURL]()

    public func reset() {
        downloads = [NSURL]()
    }

    override public func prefetchImageWithURL(url: NSURL!, options: PINRemoteImageManagerDownloadOptions) {
        downloads.append(url)
    }

}