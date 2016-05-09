//
//  NSFWService.swift
//  Ello
//
//  Created by Sean on 5/5/16.
//  Copyright © 2016 Ello. All rights reserved.
//

import Alamofire
import SwiftyJSON

public typealias NSFWSuccessCompletion = (policy: NSFWPolicy) -> Void

public struct NSFWService {

    public init(){}

    public func loadNSFWPolicy(
              success: NSFWSuccessCompletion,
              failure: ElloErrorCompletion)
    {
        Alamofire.request(.GET, "\(ElloURI.baseURL)/ios-nsfw-policy.json")
            .responseJSON { response in
                if let JSON = response.result.value,
                    alwaysViewNSFW = JSON["alwaysViewNSFW"] as? [String],
                    loggedInViewsNSFW = JSON["loggedInViewsNSFW"] as? [String],
                    currentUserViewsOwnNSFW = JSON["currentUserViewsOwnNSFW"] as? Bool
                {
                    let policy = NSFWPolicy(alwaysViewNSFW: alwaysViewNSFW, loggedInViewsNSFW: loggedInViewsNSFW, currentUserViewsOwnNSFW: currentUserViewsOwnNSFW)
                    success(policy: policy)
                }
                else {
                    let elloError = NSError.networkError(nil, code: ElloErrorCode.JSONMapping)
                    failure(error: elloError)
                }
        }
    }
}
