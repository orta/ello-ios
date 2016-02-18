//
//  ShareTrackerOverrides.swift
//  Ello
//
//  Created by Sean on 2/17/16.
//  Copyright © 2016 Ello. All rights reserved.
//

import Foundation

public enum ContentType: String {
    case Post = "Post"
    case Comment = "Comment"
}

func logPresentingAlert(name: String) {}

public class Tracker {
    public static let sharedTracker = Tracker()

    public init() {}

    static func trackRequest(headers headers: String, statusCode: Int, responseJSON: String) {}

    func contentFlagged(type: ContentType, flag: ContentFlagger.AlertOption, contentId: String) {}
    func contentFlaggingFailed(type: ContentType, message: String, contentId: String) {}
    func contentFlaggingCanceled(type: ContentType, contentId: String) {}
    func createdAtCrash(identifier: String, json: String?) {}
    func encounteredNetworkError(path: String, error: NSError, statusCode: Int?) {}
}