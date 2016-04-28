//
//  ElloProviderErrors.swift
//  Ello
//
//  Created by Sean on 2/1/16.
//  Copyright © 2016 Ello. All rights reserved.
//

import Foundation

extension ElloProvider {

    static func unCastableJSONAble(failure: ElloFailureCompletion) {
        let elloError = NSError.networkError(nil, code: ElloErrorCode.JSONMapping)
        failure(error: elloError, statusCode: 200)
    }

    public static func generateElloError(data: NSData?, statusCode: Int?) -> NSError {
        var elloNetworkError: ElloNetworkError?

        if let data = data {
            let (mappedJSON, _): (AnyObject?, NSError?) = Mapper.mapJSON(data)

            if mappedJSON != nil {
                if let node = mappedJSON?[MappingType.ErrorsType.rawValue] as? [String:AnyObject] {
                    elloNetworkError = Mapper.mapToObject(node, fromJSON: MappingType.ErrorType.fromJSON) as? ElloNetworkError
                }
            }
        }
        else if statusCode == 401 {
            elloNetworkError = ElloNetworkError(attrs: nil, code: .unauthenticated, detail: nil, messages: nil, status: "401", title: "unauthenticated")
        }

        let errorCodeType = (statusCode == nil) ? ElloErrorCode.Data : ElloErrorCode.StatusCode
        let elloError = NSError.networkError(elloNetworkError, code: errorCodeType)

        return elloError
    }

    public static func failedToSendRequest(failure: ElloFailureCompletion) {
        let elloError = NSError.networkError("Failed to send request", code: ElloErrorCode.NetworkFailure)
        failure(error: elloError, statusCode: nil)
    }

    public static func failedToMapObjects(failure: ElloFailureCompletion) {
        let jsonMappingError = ElloNetworkError(attrs: nil, code: ElloNetworkError.CodeType.unknown, detail: "NEED DEFAULT HERE", messages: nil, status: nil, title: "Unknown Error")
        let elloError = NSError.networkError(jsonMappingError, code: ElloErrorCode.JSONMapping)
        failure(error: elloError, statusCode: nil)
    }
}
