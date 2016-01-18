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
import Result
import Alamofire

public typealias ElloRequestClosure = (target: ElloAPI, success: ElloSuccessCompletion, failure: ElloFailureCompletion, invalidToken: ElloErrorCompletion)
public typealias ElloSuccessCompletion = (data: AnyObject, responseConfig: ResponseConfig) -> Void
public typealias ElloFailure = (error: NSError, statusCode: Int?)
public typealias ElloFailureCompletion = (error: NSError, statusCode: Int?) -> Void
public typealias ElloErrorCompletion = (error: NSError) -> Void
public typealias ElloEmptyCompletion = () -> Void

public class ElloProvider {
    public static var shared: ElloProvider = ElloProvider()
    public var authState: AuthState = .Initial {
        willSet {
            if newValue != authState && !authState.nextStates.contains(newValue) {
                print("invalid transition from \(authState) to \(newValue)")
            }
        }
    }

    public static var serverTrustPolicies: [String: ServerTrustPolicy] {
        var policyDict = [String: ServerTrustPolicy]()
        // make Charles plays nice in the sim by not adding a policy
        if !AppSetup.sharedState.isSimulator {
            policyDict["ello.co"] = .PinPublicKeys(
                publicKeys: ServerTrustPolicy.publicKeysInBundle(),
                validateCertificateChain: true,
                validateHost: true
            )
        }
        return policyDict
    }

    public static let manager = Manager(
        configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
        serverTrustPolicyManager: ServerTrustPolicyManager(policies: ElloProvider.serverTrustPolicies)
    )

    public static func endpointClosure(target: ElloAPI) -> Endpoint<ElloAPI> {
        let method = target.method
        let parameters = target.parameters
        let sampleResponseClosure = { return EndpointSampleResponse.NetworkResponse(200, target.sampleData) }

        let endpoint = Endpoint<ElloAPI>(URL: url(target), sampleResponseClosure: sampleResponseClosure, method: method, parameters: parameters, parameterEncoding: target.encoding)
        return endpoint.endpointByAddingHTTPHeaderFields(target.headers)
    }

    public static func DefaultProvider() -> MoyaProvider<ElloAPI> {
        return MoyaProvider<ElloAPI>(endpointClosure: ElloProvider.endpointClosure, manager: manager)
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
        elloRequest(target, success: success, failure: { _ in }, invalidToken: { _ in })
    }

    public func elloRequest(target: ElloAPI, success: ElloSuccessCompletion, failure: ElloFailureCompletion) {
        elloRequest(target, success: success, failure: failure, invalidToken: { _ in })
    }

    public func elloRequest(target: ElloAPI, success: ElloSuccessCompletion, failure: ElloFailureCompletion, invalidToken: ElloErrorCompletion) {
        let uuid = AuthState.uuid
        if authState == .Initial {
            self.attemptAuthentication((target: target, success: success, failure: failure, invalidToken: invalidToken), uuid: uuid)
        }
        else if !target.requiresAuthentication || authState.isAuthenticated {
            ElloProvider.sharedProvider.request(target) { (result) in
                self.handleRequest(target, result: result, success: success, failure: failure, invalidToken: invalidToken, uuid: uuid)
            }
            Crashlytics.sharedInstance().setObjectValue(target.path, forKey: CrashlyticsKey.RequestPath.rawValue)
        }
        else if authState.isLoggedOut {
            let elloError = NSError(domain: ElloErrorDomain, code: 401, userInfo: [NSLocalizedFailureReasonErrorKey: "Logged Out"])
            failure(error: elloError, statusCode: 401)
        }
        else {
            waitList.append((target: target, success: success, failure: failure, invalidToken: invalidToken))
        }
    }

    private func elloRequest(request: ElloRequestClosure) {
        self.elloRequest(request.target, success: request.success, failure: request.failure, invalidToken: request.invalidToken)
    }

    var waitList: [ElloRequestClosure] = []

    private let queue = dispatch_queue_create("com.ello.ReauthQueue", nil)
    private func attemptAuthentication(request: ElloRequestClosure? = nil, uuid: NSUUID) {
        dispatch_async(queue) {
            if uuid != AuthState.uuid && self.authState == .Authenticated {
                if let request = request {
                    self.elloRequest(request)
                }
                return
            }

            if let request = request {
                self.waitList.append(request)
            }

            switch self.authState {
            case .Initial:
                let authToken = AuthToken()
                if authToken.isPresent && authToken.isAuthenticated {
                    self.authState = .Authenticated
                }
                else {
                    self.authState = .LoggedOut
                }
                self.advanceAuthState(self.authState)
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
                    self.advanceAuthState(.LoggedOut)
                }, noNetwork:{
                    self.advanceAuthState(.ShouldTryUserCreds)
                })
            case .RefreshTokenSent, .UserCredsSent:
                break
            case .LoggedOut:
                self.advanceAuthState(self.authState)
            }
        }
    }

    private func advanceAuthState(nextState: AuthState) {
        dispatch_async(queue) {
            self.authState = nextState

            if nextState.isLoggedOut {
                AuthState.uuid = NSUUID()

                for request in self.waitList {
                    request.invalidToken(error: self.invalidTokenError())
                }
                self.waitList = []
                self.handleInvalidToken()
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
    }

}

// MARK: Generate error helper methods

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

// MARK: elloRequest implementation
extension ElloProvider {

    // MARK: - Private

    private func handleRequest(target: ElloAPI, result: MoyaResult, success: ElloSuccessCompletion, failure: ElloFailureCompletion, invalidToken: ElloErrorCompletion, uuid: NSUUID) {
        switch result {
        case let .Success(moyaResponse):
            let response = moyaResponse.response as? NSHTTPURLResponse
            if let response = response {
                ElloProvider_Specs.responseHeaders = response.allHeaderFields.description
                Crashlytics.sharedInstance().setObjectValue(ElloProvider_Specs.responseHeaders, forKey: CrashlyticsKey.ResponseHeaders.rawValue)
            }
            let data = moyaResponse.data
            let statusCode = moyaResponse.statusCode

            // set crashlytics stuff before processing
            Crashlytics.sharedInstance().setObjectValue("\(statusCode)", forKey: CrashlyticsKey.ResponseStatusCode.rawValue)
            ElloProvider_Specs.responseJSON = NSString(data: data, encoding: NSUTF8StringEncoding) ?? "failed to parse data"
            Crashlytics.sharedInstance().setObjectValue(ElloProvider_Specs.responseJSON, forKey: CrashlyticsKey.ResponseJSON.rawValue)
            switch statusCode {
            case 200...299, 300...399:
                handleNetworkSuccess(data, elloAPI: target, statusCode:statusCode, response: response, success: success, failure: failure)
            case 401:
                attemptAuthentication((target, success: success, failure: failure, invalidToken: invalidToken), uuid: uuid)
            case 410:
                postNetworkFailureNotification(data, statusCode: statusCode)
            default:
                handleServerError(target.path, failure: failure, data: data, statusCode: statusCode)
            }

        case let .Failure(error):
            handleNetworkFailure(target, success: success, failure: failure, invalidToken: invalidToken, error: error)
        }
    }

    private func invalidTokenError() -> NSError {
        return ElloProvider.generateElloError(nil, statusCode: nil)
    }

    private func handleInvalidToken() {
        postNetworkFailureNotification(nil, statusCode: 401)
        postNotification(AuthenticationNotifications.invalidToken, value: true)
    }

    private func parseLinked(elloAPI: ElloAPI, dict: [String:AnyObject], var responseConfig: ResponseConfig, success: ElloSuccessCompletion, failure:ElloFailureCompletion) {
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
                        responseConfig = self.parsePagination(pagination)
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

    private func handleNetworkSuccess(data:NSData, elloAPI: ElloAPI, statusCode: Int?, response: NSHTTPURLResponse?, success:ElloSuccessCompletion, failure:ElloFailureCompletion) {
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

    private func isEmptySuccess(data:NSData, statusCode: Int?) -> Bool {
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

    private func handleNetworkFailure(target: ElloAPI, success: ElloSuccessCompletion, failure: ElloFailureCompletion, invalidToken: ElloErrorCompletion, error: ErrorType?) {
        delay(1) {
            self.elloRequest(target, success: success, failure: failure, invalidToken: invalidToken)
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
