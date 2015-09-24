//
//  Mentionables.swift
//  Ello
//
//  Created by Colin Gray on 9/23/15.
//  Copyright © 2015 Ello. All rights reserved.
//

struct Mentionables {
    static func findAll(regions: [Regionable]) -> [String] {
        var mentions = [String]()
        let regex = Regex("\\B@[\\w-]+")!
        for region in regions {
            if let textRegion = region as? TextRegion {
                let matches = regex.matches(textRegion.content)
                mentions += matches
            }
        }
        return mentions
    }
}
