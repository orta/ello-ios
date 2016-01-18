//
//  ElloProvider_Specs.swift
//  Ello
//
//  Created by Colin Gray on 1/13/2016.
//  Copyright (c) 2016 Ello. All rights reserved.
//

import Moya


public struct ElloProvider_Specs {
    public static var errorStatusCode: ErrorStatusCode = .Status404

    static func errorEndpointsClosure(target: ElloAPI) -> Endpoint<ElloAPI> {
        let method = target.method
        let parameters = target.parameters
        let sampleResponseClosure = { () -> EndpointSampleResponse in
            return .NetworkResponse(ElloProvider_Specs.errorStatusCode.rawValue, ElloProvider_Specs.errorStatusCode.defaultData)
        }

        let endpoint = Endpoint<ElloAPI>(URL: url(target), sampleResponseClosure: sampleResponseClosure, method: method, parameters: parameters)
        return endpoint.endpointByAddingHTTPHeaderFields(target.headers)
    }

}


extension ElloProvider {

    public static func StubbingProvider() -> MoyaProvider<ElloAPI> {
        return MoyaProvider<ElloAPI>(endpointClosure: ElloProvider.endpointClosure, stubClosure: MoyaProvider.ImmediatelyStub)
    }

    public static func DelayedStubbingProvider() -> MoyaProvider<ElloAPI> {
        return MoyaProvider<ElloAPI>(endpointClosure: ElloProvider.endpointClosure, stubClosure: MoyaProvider.DelayedStub(1))
    }

    public static func ErrorStubbingProvider() -> MoyaProvider<ElloAPI> {
        return MoyaProvider<ElloAPI>(endpointClosure: ElloProvider_Specs.errorEndpointsClosure, stubClosure: MoyaProvider.ImmediatelyStub)
    }

}
