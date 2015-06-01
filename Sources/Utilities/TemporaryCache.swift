//
//  TemporaryCache.swift
//  Ello
//
//  Created by Colin Gray on 6/1/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

typealias TemporaryCacheEntry = (image: UIImage, expiration: NSDate)
public enum CacheKey {
    case CoverImage
    case Avatar
}
public struct TemporaryCache {
    static var coverImage: TemporaryCacheEntry?
    static var avatar: TemporaryCacheEntry?

    static func save(key: CacheKey, image: UIImage) {
        let fiveMinutes: NSTimeInterval = 5 * 60
        let date = NSDate(timeIntervalSinceNow: fiveMinutes)
        switch key {
        case .CoverImage:
            TemporaryCache.coverImage = (image: image, expiration: date)
        case .Avatar:
            TemporaryCache.avatar = (image: image, expiration: date)
        }
    }

    static func load(key: CacheKey) -> UIImage? {
        let date = NSDate()
        let entry: TemporaryCacheEntry?

        switch key {
        case .CoverImage:
            entry = TemporaryCache.coverImage
        case .Avatar:
            entry = TemporaryCache.avatar
        }

        if let entry = entry where entry.expiration.earlierDate(date) == date {
            return entry.image
        }
        return nil
    }
}
