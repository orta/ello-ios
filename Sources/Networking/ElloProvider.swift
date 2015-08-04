//
//  ElloProvider.swift
//  Ello
//
//  Created by Sean Dougherty on 12/3/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Crashlytics
import Foundation
import Moya
import WebLinking
import Alamofire

public typealias ElloSuccessCompletion = (data: AnyObject, responseConfig: ResponseConfig) -> Void
public typealias ElloFailureCompletion = (error: NSError, statusCode:Int?) -> Void
public typealias ElloErrorCompletion = (error: NSError) -> Void
public typealias ElloEmptyCompletion = () -> Void

public struct ElloProvider {

    public static var errorStatusCode:ErrorStatusCode = .Status404
    public static var responseHeaders: NSString = ""
    public static var responseJSON: NSString = ""

    public static let serverTrustPolicies: [String: ServerTrustPolicy] = [
        "ello.co": .PinPublicKeys(
            publicKeys: ServerTrustPolicy.publicKeysInBundle(),
            validateCertificateChain: true,
            validateHost: true
        )
    ]

    public static let manager = Manager(
        configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
        serverTrustPolicyManager: ServerTrustPolicyManager(policies: ElloProvider.serverTrustPolicies)
    )

    public enum ErrorStatusCode: Int {
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
            return stubbedData(String(self.rawValue))
        }

        public var notification: TypedNotification<NSError> {
            switch self {
            case .StatusUnknown:
                return TypedNotification(name: "ElloProviderNotificationUnknown")
            default:
                return TypedNotification(name: "ElloProviderNotification\(self.rawValue)")
            }
        }
    }

    public static var errorEndpointsClosure = { (target: ElloAPI) -> Endpoint<ElloAPI> in
        let method = target.method
        let parameters = target.parameters

        let sampleResponse = { () -> (EndpointSampleResponse) in
            return .Error(ElloProvider.errorStatusCode.rawValue, NSError(domain: ElloErrorDomain, code: 0, userInfo: [NSLocalizedFailureReasonErrorKey: "failure"]), { ElloProvider.errorStatusCode.defaultData })
        }()

        var endpoint = Endpoint<ElloAPI>(URL: url(target), sampleResponse: sampleResponse, method: method, parameters: parameters)

        return endpoint.endpointByAddingHTTPHeaderFields(target.headers)

    }

    public static var endpointClosure = { (target: ElloAPI) -> Endpoint<ElloAPI> in
        let method = target.method
        let parameters = target.parameters
        let sampleResponse = EndpointSampleResponse.Success(200, { target.sampleData })

        var endpoint = Endpoint<ElloAPI>(URL: url(target), sampleResponse: sampleResponse, method: method, parameters: parameters, parameterEncoding: target.encoding)
        return endpoint.endpointByAddingHTTPHeaderFields(target.headers)
    }

    public static func DefaultProvider() -> MoyaProvider<ElloAPI> {
        return MoyaProvider(endpointClosure: endpointClosure, manager: manager)
    }

    public static func StubbingProvider() -> MoyaProvider<ElloAPI> {
        return MoyaProvider(
            endpointClosure: endpointClosure,
            stubBehavior: MoyaProvider.ImmediateStubbingBehaviour,
            manager: manager
        )
    }

    public static func DelayedStubbingProvider() -> MoyaProvider<ElloAPI> {
        return MoyaProvider(endpointClosure: endpointClosure, stubBehavior: MoyaProvider.DelayedStubbingBehaviour(1))
    }

    public static func ErrorStubbingProvider() -> MoyaProvider<ElloAPI> {
        return MoyaProvider(
            endpointClosure: errorEndpointsClosure,
            stubBehavior: MoyaProvider.ImmediateStubbingBehaviour,
            manager: manager
        )
    }

    private struct SharedProvider {
        static var instance = ElloProvider.DefaultProvider()
    }

    public static var sharedProvider: MoyaProvider<ElloAPI> {
        get { return SharedProvider.instance }

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


// MARK: elloRequest implementation
extension ElloProvider {

    // public static func elloRequest(target: ElloAPI, completion: (data: AnyObject?, responseConfig: ResponseConfig?, error: NSError?, statusCode:Int?) -> Void) {
    //     elloRequest(target: target, success: { (data: AnyObject, responseConfig: ResponseConfig) in
    //             completion(data: data, responseConfig: responseConfig, error: nil)
    //         }, failure: { (error: NSError, statusCode:Int?) in
    //             completion(data: nil, responseConfig: nil, error: error, statusCode: statusCode)
    //         }, invalidToken: { (error: NSError, statusCode:Int?) in
    //             completion(data: nil, responseConfig: nil, error: error, statusCode: statusCode)
    //         })
    // }

    // MARK: - Public

    public static func elloRequest(target: ElloAPI, success: ElloSuccessCompletion, failure: ElloFailureCompletion?, invalidToken: ElloErrorCompletion? = nil) {
        ElloProvider.sharedProvider.request(target, completion: { (data, statusCode, response, error) in
            ElloProvider.handleRequest(target, data: data, response: response as? NSHTTPURLResponse, statusCode: statusCode, success: success, failure: failure, invalidToken: invalidToken, isRetry: false, error: error)
        })
        Crashlytics.sharedInstance().setObjectValue(target.path, forKey: CrashlyticsKey.RequestPath.rawValue)
    }

    public static func generateElloError(data:NSData?, error: NSError?, statusCode: Int?) -> NSError {
        var elloNetworkError:ElloNetworkError?

        if let data = data {
            let (mappedJSON: AnyObject?, error) = Mapper.mapJSON(data)
            var mappedObjects: AnyObject?

            if mappedJSON != nil && error == nil {
                if let node = mappedJSON?[MappingType.ErrorsType.rawValue] as? [String:AnyObject] {
                    elloNetworkError = Mapper.mapToObject(node, fromJSON: MappingType.ErrorType.fromJSON) as? ElloNetworkError
                }
            }
        }
        else {
            let detail = error?.elloErrorMessage ?? error?.localizedDescription ?? "NEED DEFAULT HERE"
            let jsonMappingError = ElloNetworkError(attrs: nil, code: ElloNetworkError.CodeType.unknown, detail: detail,messages: nil, status: nil, title: "Error")
        }

        var errorCodeType = (statusCode == nil) ? ElloErrorCode.Data : ElloErrorCode.StatusCode
        let elloError = NSError.networkError(elloNetworkError, code: errorCodeType)

        return elloError
    }

    public static func failedToMapObjects(failure:ElloFailureCompletion?) {
        let jsonMappingError = ElloNetworkError(attrs: nil, code: ElloNetworkError.CodeType.unknown, detail: "NEED DEFAULT HERE", messages: nil, status: nil, title: "Unknown Error")

        let elloError = NSError.networkError(jsonMappingError, code: ElloErrorCode.JSONMapping)
        if let failure = failure {
            failure(error: elloError, statusCode: nil)
        }
    }

    // MARK: - Private

    static private func handleRequest(target: ElloAPI, data: NSData?, response: NSHTTPURLResponse?, var statusCode: Int?, success: ElloSuccessCompletion, failure: ElloFailureCompletion?, invalidToken: ElloErrorCompletion?, isRetry: Bool, error: NSError?) {
        if let response = response {
            ElloProvider.responseHeaders = response.allHeaderFields.description
            Crashlytics.sharedInstance().setObjectValue(ElloProvider.responseHeaders, forKey: CrashlyticsKey.ResponseHeaders.rawValue)
        }
        if data != nil && statusCode != nil {
            // set crashlytics stuff before processing
            Crashlytics.sharedInstance().setObjectValue("\(statusCode!)", forKey: CrashlyticsKey.ResponseStatusCode.rawValue)
            ElloProvider.responseJSON = NSString(data: data!, encoding: NSUTF8StringEncoding) ?? "failed to parse data"
            Crashlytics.sharedInstance().setObjectValue(ElloProvider.responseJSON, forKey: CrashlyticsKey.ResponseJSON.rawValue)
            switch statusCode! {
            case 200...299:
                ElloProvider.handleNetworkSuccess(data!, elloAPI: target, statusCode:statusCode, response: response, success: success, failure: failure)
            case 300...399:
                ElloProvider.handleNetworkSuccess(data!, elloAPI: target, statusCode:statusCode, response: response, success: success, failure: failure)
            case 401:
                if !isRetry {
                    let token = AuthToken().token
                    let authService = AuthService()
                    authService.reAuthenticate({
                        // now retry the previous request that generated the original 401
                        self.retryRequest(target, success: success, failure: failure)
                    },
                    failure: { _ in
                        // if the token has changed, then some *other* network request probably issued
                        // a 'refreshToken' request that *succeeded*.
                        if AuthToken().isValid && token != AuthToken().token {
                            self.retryRequest(target, success: success, failure: failure)
                        }
                        else {
                            self.handleInvalidToken(data, statusCode: statusCode, invalidToken: invalidToken, error: error)
                        }
                    })
                }
                else {
                    handleInvalidToken(data, statusCode: statusCode, invalidToken: invalidToken, error: error)
                }
            case 410:
                ElloProvider.postNetworkFailureNotification(data, error: error, statusCode: statusCode)
            case 422:
                ElloProvider.handleNetworkFailure(target.path, failure: failure, data: data, error: error, statusCode: statusCode)
            case 402...409:
                ElloProvider.handleNetworkFailure(target.path, failure: failure, data: data, error: error, statusCode: statusCode)
            case 400...499:
                ElloProvider.handleNetworkFailure(target.path, failure: failure, data: data, error: error, statusCode: statusCode)
            case 500...599:
                ElloProvider.handleNetworkFailure(target.path, failure: failure, data: data, error: error, statusCode: statusCode)
            default:
                ElloProvider.handleNetworkFailure(target.path, failure: failure, data: data, error: error, statusCode: statusCode)
            }
        }
        else {
            Crashlytics.sharedInstance().setObjectValue("nil", forKey: CrashlyticsKey.ResponseStatusCode.rawValue)
            ElloProvider.responseJSON = "no json data"
            Crashlytics.sharedInstance().setObjectValue(ElloProvider.responseJSON, forKey: CrashlyticsKey.ResponseJSON.rawValue)
            ElloProvider.handleNetworkFailure(target.path, failure: failure, data: data, error: error, statusCode: statusCode)
        }
    }

    static private func handleInvalidToken(data: NSData?, statusCode: Int?, invalidToken: ElloErrorCompletion?, error: NSError?) {
        ElloProvider.postNetworkFailureNotification(data, error: error, statusCode: statusCode)
        postNotification(AuthenticationNotifications.invalidToken, true)
        let elloError = generateElloError(data, error: error, statusCode: statusCode)
        invalidToken?(error: elloError)
    }

    static private func retryRequest(target: ElloAPI, success: ElloSuccessCompletion, failure: ElloFailureCompletion?, invalidToken: ElloErrorCompletion? = nil) {
        ElloProvider.sharedProvider.request(target, completion: { (data, statusCode, response, error) in
            ElloProvider.handleRequest(target, data: data, response: response as? NSHTTPURLResponse, statusCode: statusCode, success: success, failure: failure, invalidToken: invalidToken, isRetry: true, error: error)
        })
    }

    static private func parseLinked(elloAPI: ElloAPI, dict: [String:AnyObject], var responseConfig: ResponseConfig, success: ElloSuccessCompletion, failure:ElloFailureCompletion?) {
        var mappedObjects: AnyObject?
        let completion: ElloEmptyCompletion = {
            if let node = dict[elloAPI.mappingType.rawValue] as? [[String:AnyObject]] {
                mappedObjects = Mapper.mapToObjectArray(node, fromJSON: elloAPI.mappingType.fromJSON)
            }
            else if let node = dict[elloAPI.mappingType.rawValue] as? [String:AnyObject] {
                mappedObjects = Mapper.mapToObject(node, fromJSON: elloAPI.mappingType.fromJSON)
                if  let pagingPath = elloAPI.pagingPath,
                    let links = node["links"] as? [String:AnyObject],
                    let pagingPathNode = links[pagingPath] as? [String:AnyObject]
                {
                    if let pagination = pagingPathNode["pagination"] as? [String:String] {
                        responseConfig = ElloProvider.parsePagination(pagination)
                    }
                }
            }
            if let mappedObjects: AnyObject = mappedObjects {
                success(data: mappedObjects, responseConfig: responseConfig)
            }
            else {
                ElloProvider.failedToMapObjects(failure)
            }
        }

        if let linked = dict["linked"] as? [String:[[String:AnyObject]]] {
            ElloLinkedStore.sharedInstance.parseLinked(linked, completion: completion)
        }
        else {
            completion()
        }
    }

    static private func handleNetworkSuccess(data:NSData, elloAPI: ElloAPI, statusCode: Int?, response: NSHTTPURLResponse?, success:ElloSuccessCompletion, failure:ElloFailureCompletion?) {
        let (mappedJSON: AnyObject?, error) = Mapper.mapJSON(data)
        var responseConfig = parseResponse(response)
        if mappedJSON != nil && error == nil {
            if let dict = mappedJSON as? [String:AnyObject] {
                parseLinked(elloAPI, dict: dict, responseConfig: responseConfig, success: success, failure: failure)
            }
            else {
                failedToMapObjects(failure)
            }
        }
        else if isEmptySuccess(data, statusCode: statusCode) {
            let emptyString = ""
            success(data: emptyString, responseConfig: responseConfig)
        }
        else {
            failedToMapObjects(failure)
        }
    }

    static private func isEmptySuccess(data:NSData, statusCode: Int?) -> Bool {
        // accepted || no content
        if statusCode == 202 || statusCode == 204 {
            return true
        }
        // no content
        return  NSString(data: data, encoding: NSUTF8StringEncoding) == "" &&
                statusCode >= 200 &&
                statusCode < 400
    }

    static private func postNetworkFailureNotification(data:NSData?, error: NSError?, statusCode: Int?) {
        let elloError = generateElloError(data, error: error, statusCode: statusCode)
        let notificationCase:ElloProvider.ErrorStatusCode
        if let statusCode = statusCode {
            if let noteCase = ElloProvider.ErrorStatusCode(rawValue: statusCode) {
                notificationCase = noteCase
            }
            else {
                notificationCase = ElloProvider.ErrorStatusCode.StatusUnknown
            }
        }
        else {
            notificationCase = ElloProvider.ErrorStatusCode.StatusUnknown
        }

        postNotification(notificationCase.notification, elloError)
    }

    static private func handleNetworkFailure(path: String, failure:ElloFailureCompletion?, data:NSData?, error: NSError?, statusCode: Int?) {
        let elloError = generateElloError(data, error: error, statusCode: statusCode)
        Tracker.sharedTracker.encounteredNetworkError(path, error: elloError, statusCode: statusCode)
        failure?(error: elloError, statusCode: statusCode)
    }

    static private func parsePagination(node: [String: String]) -> ResponseConfig {
        var config = ResponseConfig()
        config.totalPages = node["total_pages"]
        config.totalCount = node["total_count"]
        config.totalPagesRemaining = node["total_pages_remaining"]
        if let next = node["next"] {
            if let comps = NSURLComponents(string: next) {
                config.nextQueryItems = comps.queryItems
            }
        }
        if let prev = node["prev"] {
            if let comps = NSURLComponents(string: prev) {
                config.prevQueryItems = comps.queryItems
            }
        }
        if let first = node["first"] {
            if let comps = NSURLComponents(string: first) {
                config.firstQueryItems = comps.queryItems
            }
        }
        if let last = node["last"] {
            if let comps = NSURLComponents(string: last) {
                config.lastQueryItems = comps.queryItems
            }
        }
        return config
    }

    static private func parseResponse(response: NSHTTPURLResponse?) -> ResponseConfig {
        var config = ResponseConfig()
        config.statusCode = response?.statusCode
        config.lastModified = response?.allHeaderFields["Last-Modified"] as? String
        config.totalPages = response?.allHeaderFields["X-Total-Pages"] as? String
        config.totalCount = response?.allHeaderFields["X-Total-Count"] as? String
        config.totalPagesRemaining = response?.allHeaderFields["X-Total-Pages-Remaining"] as? String
        if let nextLink = response?.findLink(relation: "next") {
            if let comps = NSURLComponents(string: nextLink.uri) {
                config.nextQueryItems = comps.queryItems
            }
        }
        if let prevLink = response?.findLink(relation: "prev") {
            if let comps = NSURLComponents(string: prevLink.uri) {
                config.prevQueryItems = comps.queryItems
            }
        }
        if let firstLink = response?.findLink(relation: "first") {
            if let comps = NSURLComponents(string: firstLink.uri) {
                config.firstQueryItems = comps.queryItems
            }
        }
        if let lastLink = response?.findLink(relation: "last") {
            if let comps = NSURLComponents(string: lastLink.uri) {
                config.lastQueryItems = comps.queryItems
            }
        }
        return config
    }
}
