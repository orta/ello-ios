//
//  NSErrorExtensions.swift
//  Ello
//
//  Created by Colin Gray on 4/30/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit

extension NSError {

    var elloErrorMessage: String? {
        if let elloNetworkError = self.userInfo[NSLocalizedFailureReasonErrorKey] as? ElloNetworkError {
            return elloNetworkError.title
        }
        return nil
    }

}
