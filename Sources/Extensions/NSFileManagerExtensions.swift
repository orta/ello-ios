//
//  NSFileManagerExtensions.swift
//  Ello
//
//  Created by Sean on 3/11/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

public extension NSFileManager {

    class func ElloDocumentsDir() -> String {
        return NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] 
    }
}
