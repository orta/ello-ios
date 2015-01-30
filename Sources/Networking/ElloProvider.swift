//
//  ElloProvider.swift
//  Ello
//
//  Created by Sean Dougherty on 12/3/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Foundation
import Moya

typealias ElloSuccessCompletion = (data: AnyObject) -> ()
typealias ElloFailureCompletion = (error: NSError, statusCode:Int?) -> ()


struct ElloProvider {

    static var errorStatusCode:ErrorStatusCode = .Status404

    enum ErrorStatusCode: Int {
        case Status401 = 401
        case Status403 = 403
        case Status404 = 404
        case Status410 = 410
        case Status420 = 420
        case Status422 = 422
        case Status500 = 500
        case Status502 = 502
        case Status503 = 503
        case StatusUnknown = 1_000_000

        var defaultData: NSData {
            return stubbedResponse(String(self.rawValue))
        }

        var notificationName: NSString {
            switch self {
            case .StatusUnknown:
                return "ElloProviderNotificationUnknown"
            default:
                return "ElloProviderNotification\(self.rawValue)"
            }
        }
    }

    static var errorEndpointsClosure = { (target: ElloAPI, method: Moya.Method, parameters: [String: AnyObject]) -> Endpoint<ElloAPI> in
 
        let sampleResponse = { () -> (EndpointSampleResponse) in
            return .Error(ElloProvider.errorStatusCode.rawValue, NSError(domain: ElloErrorDomain, code: 0, userInfo: [NSLocalizedFailureReasonErrorKey: "failure"]), ElloProvider.errorStatusCode.defaultData)
        }()

        var endpoint = Endpoint<ElloAPI>(URL: url(target), sampleResponse: sampleResponse, method: method, parameters: parameters)

        switch target {
        case .Auth, .ReAuth:
            return endpoint
        default:
            return endpoint.endpointByAddingHTTPHeaderFields(["Content-Type": "application/json", "Authorization": AuthToken().tokenWithBearer ?? "", "Accept-Language": ""])
        }
    }

    static var endpointsClosure = { (target: ElloAPI, method: Moya.Method, parameters: [String: AnyObject]) -> Endpoint<ElloAPI> in
        var endpoint = Endpoint<ElloAPI>(URL: url(target), sampleResponse: .Success(200, target.sampleData), method: method, parameters: parameters)

        switch target {
        case .Auth, .ReAuth:
            return endpoint
        default:
            return endpoint.endpointByAddingHTTPHeaderFields(["Authorization": AuthToken().tokenWithBearer ?? "", "Accept-Language": ""])
        }
    }

    static func DefaultProvider() -> MoyaProvider<ElloAPI> {
        return MoyaProvider(endpointsClosure: endpointsClosure, stubResponses: false)
    }

    static func StubbingProvider() -> MoyaProvider<ElloAPI> {
        return MoyaProvider(endpointsClosure: endpointsClosure, stubResponses: true)
    }

    private struct SharedProvider {
        static var instance = ElloProvider.DefaultProvider()
    }

    static var sharedProvider: MoyaProvider<ElloAPI> {
        get {
        return SharedProvider.instance
        }

        set (newSharedProvider) {
            SharedProvider.instance = newSharedProvider
        }
    }

    static func unCastableJSONAble(failure:ElloFailureCompletion?) {
        if let failure = failure {
            let elloError = NSError.networkError(nil, code: ElloErrorCode.JSONMapping)
            failure(error:elloError, statusCode:200)
        }
    }
}

extension MoyaProvider {

    func elloRequest(token: T, method: Moya.Method, parameters: [String: AnyObject], propertyName: MappingType.Prop, success: ElloSuccessCompletion, failure: ElloFailureCompletion?) {

        self.request(token, method: method, parameters: parameters, completion: {
            (data, statusCode, response, error) in

            self.handleRequest(token, method: method, parameters: parameters, data: data, statusCode: statusCode, success: success, failure: failure, isRetry: false, propertyName: propertyName, error: error)
        })
    }

    func handleRequest(token: T, method: Moya.Method, parameters: [String: AnyObject], data:NSData?, var statusCode:Int?, success: ElloSuccessCompletion, failure: ElloFailureCompletion?, isRetry: Bool, propertyName: MappingType.Prop, error:NSError?) {
        if data != nil && statusCode != nil {
            switch statusCode! {
            case 200...299:
                self.handleNetworkSuccess(data!, propertyName: propertyName, success: success, failure: failure)
            case 300...399:
                self.handleNetworkSuccess(data!, propertyName: propertyName, success: success, failure: failure)
            case 401:
                if !isRetry {
                    let authService = AuthService()
                    authService.reAuthenticate({
                        // now retry the previous request that generated the original 401
                        self.request(token, method: method, parameters: parameters, completion: { (data, statusCode, response, error) in
                            self.handleRequest(token, method: method, parameters: parameters, data: data, statusCode: statusCode, success: success, failure: failure, isRetry: true, propertyName: propertyName, error: error)
                        })
                    },
                    failure: { (_,_) in
                        self.postNetworkFailureNotification(data, error: error, statusCode: statusCode)
                    })
                } else {
                    self.postNetworkFailureNotification(data, error: error, statusCode: statusCode)
                }
            case 410:
                self.postNetworkFailureNotification(data, error: error, statusCode: statusCode)
            case 422:
                self.handleNetworkFailure(failure, data: data, error: error, statusCode: statusCode)
            case 402...409:
                self.handleNetworkFailure(failure, data: data, error: error, statusCode: statusCode)
            case 400...499:
                self.handleNetworkFailure(failure, data: data, error: error, statusCode: statusCode)
            case 500...599:
                self.handleNetworkFailure(failure, data: data, error: error, statusCode: statusCode)
            default:
                self.handleNetworkFailure(failure, data: data, error: error, statusCode: statusCode)
            }
        }
        else {
            self.handleNetworkFailure(failure, data: data, error: error, statusCode: statusCode)
        }
    }

    func handleNetworkSuccess(data:NSData, propertyName: MappingType.Prop, success:ElloSuccessCompletion, failure:ElloFailureCompletion?) {
        let (mappedJSON: AnyObject?, error) = mapJSON(data)
        
        var mappedObjects: AnyObject?
        if mappedJSON != nil && error == nil {
            if let dict = mappedJSON as? [String:AnyObject] {
                let linked = dict["linked"] as? [String:[[String:AnyObject]]]

                if linked != nil {
                    Store.parseLinked(linked!)
                }

                if let node = dict[propertyName.rawValue] as? [[String:AnyObject]] {
                    if let JSONAbleType = MappingType.types[propertyName] {
                        mappedObjects = mapToObjectArray(node, classType: JSONAbleType, linked: Store)
                    }
                }
                else if let node = dict[propertyName.rawValue] as? [String:AnyObject] {
                    if let JSONAbleType = MappingType.types[propertyName] {
                        mappedObjects = mapToObject(node, classType: JSONAbleType, linked: Store)
                    }
                }
            }

            if let mappedObjects: AnyObject = mappedObjects {
                success(data:mappedObjects)
            }
            else {
                failedToMapObjects(failure)
            }

        }
        else {
            failedToMapObjects(failure)
        }
    }

    func failedToMapObjects(failure:ElloFailureCompletion?) {
        let jsonMappingError = ElloNetworkError(title: "Unknown Error", code: ElloNetworkError.CodeType.unknown.rawValue, detail: "NEED DEFAULT HERE", status: nil, messages: nil, attrs: nil)

        let elloError = NSError.networkError(jsonMappingError, code: ElloErrorCode.JSONMapping)
        if let failure = failure {
            failure(error: elloError, statusCode: nil)
        }
    }

    func postNetworkFailureNotification(data:NSData?, error: NSError?, statusCode: Int?) {
        let elloError = generateElloError(data, error: error, statusCode: statusCode)
        var notificationCase:ElloProvider.ErrorStatusCode?
        if let statusCode = statusCode {
            notificationCase = ElloProvider.ErrorStatusCode(rawValue: statusCode)
        }

        if notificationCase == nil {
            notificationCase = ElloProvider.ErrorStatusCode.StatusUnknown
        }

        NSNotificationCenter.defaultCenter().postNotificationName(notificationCase!.notificationName, object: elloError)
    }

    func handleNetworkFailure(failure:ElloFailureCompletion?, data:NSData?, error: NSError?, statusCode: Int?) {
        let elloError = generateElloError(data, error: error, statusCode: statusCode)

        if let failure = failure {
            failure(error: elloError, statusCode: statusCode)
        }
        else {
            self.postNetworkFailureNotification(data, error: error, statusCode: statusCode)
        }
    }

    func generateElloError(data:NSData?, error: NSError?, statusCode: Int?) -> NSError {
        var elloNetworkError:ElloNetworkError?
        
        if let data = data {
            let (mappedJSON: AnyObject?, error) = mapJSON(data)
            var mappedObjects: AnyObject?

            if mappedJSON != nil && error == nil {
                if let node = mappedJSON?[MappingType.Prop.Errors.rawValue] as? [String:AnyObject] {
                    elloNetworkError = mapToObject(node, classType: ElloNetworkError.self, linked: Store) as? ElloNetworkError
                }
            }
        }
        else {
            let detail = error?.localizedDescription ?? "NEED DEFAULT HERE"
            elloNetworkError = ElloNetworkError(title: "Error", code: ElloNetworkError.CodeType.unknown.rawValue, detail: detail, status: nil, messages: nil, attrs: nil)
        }

        var errorCodeType = (statusCode == nil) ? ElloErrorCode.Data : ElloErrorCode.StatusCode
        let elloError = NSError.networkError(elloNetworkError, code: errorCodeType)

        return elloError
    }

    func mapJSON(data: NSData) -> (AnyObject?, NSError?) {

        var error: NSError?
        var json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &error)
        
        if json == nil && error != nil {
            var userInfo: [NSObject : AnyObject]? = ["data": data]
            error = NSError(domain: ElloErrorDomain, code: ElloErrorCode.JSONMapping.rawValue, userInfo: userInfo)
        }

        return (json, error)
    }

    func mapToObjectArray(object: AnyObject?, classType: JSONAble.Type, linked:ElloLinkedStore) -> [JSONAble]? {

        if let dicts = object as? [[String:AnyObject]] {
            let jsonables:[JSONAble] =  dicts.map({ return classType.fromJSON($0) })
            return jsonables
        }

        return nil
    }

    func mapToObject(object:AnyObject?, classType: JSONAble.Type, linked:ElloLinkedStore) -> JSONAble? {
    
        if let dict = object as? [String:AnyObject] {
            return classType.fromJSON(dict)
        }
        else {
            return nil
        }
    }
}