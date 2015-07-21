//
//  ContentFlaggingService.swift
//  Ello
//
//  Created by Sean on 2/25/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit
import Moya
import SwiftyJSON


public typealias ContentFlaggingSuccessCompletion = () -> Void

public struct ContentFlaggingService {

    public init(){}

    public func flagContent(endpoint: ElloAPI, success: ContentFlaggingSuccessCompletion, failure: ElloFailureCompletion?) {
        ElloProvider.elloRequest(endpoint,
            success: { data in
                success()
        }, failure: failure)
    }
}
