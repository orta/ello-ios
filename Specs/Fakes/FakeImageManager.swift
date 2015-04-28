//
//  FakeImageManager.swift
//  Ello
//
//  Created by Sean on 4/28/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import SDWebImage

public class FakeImageManager: SDWebImageManager {

    public var downloads = [NSURL]()

    public func reset() {
        downloads = [NSURL]()
    }

    public override init(){}

    override public func downloadImageWithURL(url: NSURL!, options: SDWebImageOptions, progress progressBlock: SDWebImageDownloaderProgressBlock!, completed completedBlock: SDWebImageCompletionWithFinishedBlock!) -> SDWebImageOperation! {
        downloads.append(url)
        return FakeSDWebImageOperation()
    }

}

// SDWebImageOperation is a protocol so we need a fake one to be returned from downloadImageWithURL()
public class FakeSDWebImageOperation:NSObject, SDWebImageOperation {
    public func cancel(){}
}