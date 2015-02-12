//
//  Streamable.swift
//  Ello
//
//  Created by Sean on 1/20/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

enum StreamableKind {
    case Comment
    case Post
    case WelcomePost
}

protocol Streamable {
    var author:User? { get }
    var createdAt:NSDate { get }
    var kind:StreamableKind { get }
    var content:[Regionable]? { get }
    var groupId:String { get }
}
