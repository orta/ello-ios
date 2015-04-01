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

typealias ContentFlaggingSuccessCompletion = () -> ()


struct ContentFlaggingService {

    func flagContent(endpoint: ElloAPI, success: ContentFlaggingSuccessCompletion, failure: ElloFailureCompletion?) {
        ElloProvider.sharedProvider.elloRequest(endpoint,
            method: .POST,
            success: { data in
                success()
        }, failure: failure)
    }

}