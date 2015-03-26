//
//  Array.swift
//  Ello
//
//  Created by Gordon Fontenot on 3/26/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

extension Array {
    func safeValue(index: Int) -> T? {
        return contains(startIndex..<endIndex, index) ? self[index] : .None
    }
}
