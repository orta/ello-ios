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
import Result
import Alamofire

public typealias ElloRequestClosure = (target: ElloAPI, success: ElloSuccessCompletion, failure: ElloFailureCompletion)
public typealias ElloSuccessCompletion = (data: AnyObject, responseConfig: ResponseConfig) -> Void
public typealias ElloFailure = (error: NSError, statusCode: Int?)
public typealias ElloFailureCompletion = (error: NSError, statusCode: Int?) -> Void
public typealias ElloErrorCompletion = (error: NSError) -> Void
public typealias ElloEmptyCompletion = () -> Void

public class ElloProvider {
    public static var shared: ElloProvider = ElloProvider()
    public static var currentUser: User?
    public static var nsfwPolicy: NSFWPolicy?
    public var authState: AuthState = .Initial {
        willSet {
            if newValue != authState && !authState.canTransitionTo(newValue) && !AppSetup.sharedState.isTesting {
                print("invalid transition from \(authState) to \(newValue)")
            }
        }
    }

    public static func endpointClosure(target: ElloAPI) -> Endpoint<ElloAPI> {
        let sampleResponseClosure = { return EndpointSampleResponse.NetworkResponse(200, target.sampleData) }

        let method = target.method
        let parameters = target.parameters
        let endpoint = Endpoint<ElloAPI>(URL: url(target), sampleResponseClosure: sampleResponseClosure, method: method, parameters: parameters, parameterEncoding: target.encoding)
        return endpoint.endpointByAddingHTTPHeaderFields(target.headers(currentUser, policy: nsfwPolicy))
    }

    public static func DefaultProvider() -> MoyaProvider<ElloAPI> {
        return MoyaProvider<ElloAPI>(endpointClosure: ElloProvider.endpointClosure, manager: ElloManager.manager)
    }

    public static func ShareExtensionProvider() -> MoyaProvider<ElloAPI> {
        return MoyaProvider<ElloAPI>(endpointClosure: ElloProvider.endpointClosure, manager: ElloManager.shareExtensionManager)
    }

    private struct SharedProvider {
        static var instance = ElloProvider.DefaultProvider()
    }

    public static var oneTimeProvider: MoyaProvider<ElloAPI>?
    public static var sharedProvider: MoyaProvider<ElloAPI> {
        get {
            if let provider = oneTimeProvider {
                oneTimeProvider = nil
                return provider
            }
            return SharedProvider.instance
        }

        set (newSharedProvider) {
            SharedProvider.instance = newSharedProvider
        }
    }

    // MARK: - Public

    public func elloRequest(target: ElloAPI, success: ElloSuccessCompletion) {
        elloRequest((target: target, success: success, failure: { _ in }))
    }

    public func elloRequest(target: ElloAPI, success: ElloSuccessCompletion, failure: ElloFailureCompletion) {
        elloRequest((target: target, success: success, failure: failure))
    }

    public func elloRequest(request: ElloRequestClosure) {
        let target = request.target
        let success = request.success
        let failure = request.failure
        let uuid = AuthState.uuid

        if authState.isUndetermined {
            self.attemptAuthentication(request, uuid: uuid)
        }
        else if authState.isTransitioning {
            waitList.append(request)
        }
        else {
            let canMakeRequest = authState.supports(target)
            if canMakeRequest {
                Crashlytics.sharedInstance().setObjectValue(target.path, forKey: CrashlyticsKey.RequestPath.rawValue)
                ElloProvider.sharedProvider.request(target) { (result) in
                    self.handleRequest(target, result: result, success: success, failure: failure, uuid: uuid)
                }
            }
            else {
                requestFailed(failure)
            }
        }
    }

    private func requestFailed(failure: ElloFailureCompletion) {
        let elloError = NSError(domain: ElloErrorDomain, code: 401, userInfo: [NSLocalizedFailureReasonErrorKey: "Logged Out"])
        failure(error: elloError, statusCode: 401)
    }

    var waitList: [ElloRequestClosure] = []

    public func logout() {
        if authState.canTransitionTo(.NoToken) {
            self.advanceAuthState(.NoToken)
        }
    }

    public func authenticated(isPasswordBased isPasswordBased: Bool) {
        if isPasswordBased {
            self.advanceAuthState(.Authenticated)
        }
        else {
            self.advanceAuthState(.Anonymous)
        }
    }

    // set queue to nil in specs, and reauth requests are sent synchronously.
    var queue: dispatch_queue_t? = dispatch_queue_create("com.ello.ReauthQueue", nil)
    private func attemptAuthentication(request: ElloRequestClosure? = nil, uuid: NSUUID) {
        let closure = {
            let shouldResendRequest = uuid != AuthState.uuid
            if let request = request where shouldResendRequest {
                self.elloRequest(request)
                return
            }

            if let request = request {
                self.waitList.append(request)
            }

            switch self.authState {
            case .Initial:
                let authToken = AuthToken()
                if authToken.isPasswordBased {
                    self.authState = .Authenticated
                }
                else if authToken.isAnonymous {
                    self.authState = .Anonymous
                }
                else {
                    self.authState = .ShouldTryAnonymousCreds
                }
                self.advanceAuthState(self.authState)
            case .Anonymous:
                // an anonymous-authenticated request resulted in a 401 - we
                // should log the user out
                self.advanceAuthState(.NoToken)
            case .Authenticated, .ShouldTryRefreshToken:
                self.authState = .RefreshTokenSent

                let authService = ReAuthService()
                authService.reAuthenticateToken(success: {
                    self.advanceAuthState(.Authenticated)
                },
                failure: { _ in
                    self.advanceAuthState(.ShouldTryUserCreds)
                }, noNetwork:{
                    self.advanceAuthState(.ShouldTryRefreshToken)
                })
            case .ShouldTryUserCreds:
                self.authState = .UserCredsSent

                let authService = ReAuthService()
                authService.reAuthenticateUserCreds(success: {
                    self.advanceAuthState(.Authenticated)
                },
                failure: { _ in
                    self.advanceAuthState(.NoToken)
                }, noNetwork:{
                    self.advanceAuthState(.ShouldTryUserCreds)
                })
            case .ShouldTryAnonymousCreds, .NoToken:
                self.authState = .AnonymousCredsSent

                let authService = AnonymousAuthService()
                authService.authenticateAnonymously(success: {
                    self.advanceAuthState(.Anonymous)
                }, failure: { _ in
                    self.advanceAuthState(.NoToken)
                }, noNetwork: {
                    self.advanceAuthState(.ShouldTryAnonymousCreds)
                })
            case .RefreshTokenSent, .UserCredsSent, .AnonymousCredsSent:
                break
            }
        }
        if let queue = queue {
            dispatch_async(queue, closure)
        }
        else {
            closure()
        }
    }

    private func advanceAuthState(nextState: AuthState) {
        let closure = {
            self.authState = nextState

            if nextState == .NoToken {
                AuthState.uuid = NSUUID()
                AuthToken.reset()

                for request in self.waitList {
                    if nextState.supports(request.target) {
                        self.elloRequest(request)
                    }
                    else {
                        self.requestFailed(request.failure)
                    }
                }
                self.waitList = []
                nextTick {
                    self.postInvalidTokenNotification()
                }
            }
            else if nextState == .Anonymous {
                // if you were using the app, but got logged out, you will
                // quickly receive an anonymous token.  If any Requests don't
                // support this flow , we should kick you out and present the
                // log in screen.  During login/join, though, all the Requests
                // *will* support an anonymous token.
                //
                // if, down the road, we have anonymous browsing, we should
                // require and implement robust invalidToken handlers for all
                // Controllers & Services

                AuthState.uuid = NSUUID()

                for request in self.waitList {
                    if !nextState.supports(request.target) {
                        self.requestFailed(request.failure)
                    }
                    else {
                        self.elloRequest(request)
                    }
                }
                self.waitList = []
            }
            else if nextState.isAuthenticated {
                AuthState.uuid = NSUUID()

                for request in self.waitList {
                    self.elloRequest(request)
                }
                self.waitList = []
            }
            else {
                sleep(1)
                self.attemptAuthentication(uuid: AuthState.uuid)
            }
        }
        if let queue = queue {
            dispatch_async(queue, closure)
        }
        else {
            closure()
        }
    }

}


// MARK: elloRequest implementation
extension ElloProvider {

    // MARK: - Private

    private func handleRequest(target: ElloAPI, result: MoyaResult, success: ElloSuccessCompletion, failure: ElloFailureCompletion, uuid: NSUUID) {
        switch result {
        case let .Success(moyaResponse):
            let response = moyaResponse.response as? NSHTTPURLResponse
            let data = moyaResponse.data
            let statusCode = moyaResponse.statusCode
            if let response = response {
                // set crashlytics stuff before processing
                let headers = response.allHeaderFields.description
                let responseJSON = NSString(data: data, encoding: NSUTF8StringEncoding) as? String ?? "failed to parse data"
                Tracker.trackRequest(headers: headers, statusCode: statusCode, responseJSON: responseJSON)
            }

            switch statusCode {
            case 200...299, 300...399:
                handleNetworkSuccess(data, elloAPI: target, statusCode:statusCode, response: response, success: success, failure: failure)
            case 401:
                attemptAuthentication((target, success: success, failure: failure), uuid: uuid)
            case 410:
                postNetworkFailureNotification(data, statusCode: statusCode)
            default:
                handleServerError(target.path, failure: failure, data: data, statusCode: statusCode)
            }

        case let .Failure(error):
            handleNetworkFailure(target, success: success, failure: failure, error: error)
        }
    }

    private func postInvalidTokenNotification() {
        postNetworkFailureNotification(nil, statusCode: 401)
        postNotification(AuthenticationNotifications.invalidToken, value: true)
    }

    private func parseLinked(elloAPI: ElloAPI, dict: [String:AnyObject], responseConfig: ResponseConfig, success: ElloSuccessCompletion, failure: ElloFailureCompletion) {
        var newResponseConfig: ResponseConfig?
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
                        newResponseConfig = self.parsePagination(pagination)
                    }
                }
            }
            if let mappedObjects: AnyObject = mappedObjects {
                success(data: mappedObjects, responseConfig: newResponseConfig ?? responseConfig)
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

    private func handleNetworkSuccess(data: NSData, elloAPI: ElloAPI, statusCode: Int?, response: NSHTTPURLResponse?, success: ElloSuccessCompletion, failure: ElloFailureCompletion) {
        let (mappedJSON, error): (AnyObject?, NSError?) = Mapper.mapJSON(data)
        let responseConfig = parseResponse(response)
        if mappedJSON != nil && error == nil {
            if let dict = mappedJSON as? [String:AnyObject] {
                parseLinked(elloAPI, dict: dict, responseConfig: responseConfig, success: success, failure: failure)
            }
            else {
                ElloProvider.failedToMapObjects(failure)
            }
        }
        else if isEmptySuccess(data, statusCode: statusCode) {
            let emptyString = ""
            success(data: emptyString, responseConfig: responseConfig)
        }
        else {
            ElloProvider.failedToMapObjects(failure)
        }
    }

    private func isEmptySuccess(data: NSData, statusCode: Int?) -> Bool {
        // accepted || no content
        if statusCode == 202 || statusCode == 204 {
            return true
        }
        // no content
        return  NSString(data: data, encoding: NSUTF8StringEncoding) == "" &&
                statusCode >= 200 &&
                statusCode < 400
    }

    private func postNetworkFailureNotification(data: NSData?, statusCode: Int?) {
        let elloError = ElloProvider.generateElloError(data, statusCode: statusCode)
        let notificationCase: ErrorStatusCode
        if let statusCode = statusCode {
            if let noteCase = ErrorStatusCode(rawValue: statusCode) {
                notificationCase = noteCase
            }
            else {
                notificationCase = ErrorStatusCode.StatusUnknown
            }
        }
        else {
            notificationCase = ErrorStatusCode.StatusUnknown
        }

        postNotification(notificationCase.notification, value: elloError)
    }

    private func handleServerError(path: String, failure: ElloFailureCompletion, data: NSData?, statusCode: Int?) {
        let elloError = ElloProvider.generateElloError(data, statusCode: statusCode)
        Tracker.sharedTracker.encounteredNetworkError(path, error: elloError, statusCode: statusCode)
        failure(error: elloError, statusCode: statusCode)
    }

    private func handleNetworkFailure(target: ElloAPI, success: ElloSuccessCompletion, failure: ElloFailureCompletion, error: ErrorType?) {
        delay(1) {
            self.elloRequest(target, success: success, failure: failure)
        }
    }

    private func parsePagination(node: [String: String]) -> ResponseConfig {
        let config = ResponseConfig()
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

    private func parseResponse(response: NSHTTPURLResponse?) -> ResponseConfig {
        let config = ResponseConfig()
        config.statusCode = response?.statusCode
        config.lastModified = response?.allHeaderFields["Last-Modified"] as? String
        config.totalPages = response?.allHeaderFields["X-Total-Pages"] as? String
        config.totalCount = response?.allHeaderFields["X-Total-Count"] as? String
        config.totalPagesRemaining = response?.allHeaderFields["X-Total-Pages-Remaining"] as? String

        return parseLinks(response, config: config)
    }
}
