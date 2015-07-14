//
//  AutoCompleteService.swift
//  Ello
//
//  Created by Sean on 6/30/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public typealias AutoCompleteServiceSuccessCompletion = (results: [AutoCompleteResult], responseConfig: ResponseConfig) -> ()

public struct AutoCompleteService {

    public init(){}

    public func loadResults(
        terms: String,
        type: AutoCompleteType,
        success: AutoCompleteServiceSuccessCompletion,
        failure: ElloFailureCompletion?)
    {
        let endpoint: ElloAPI = type == AutoCompleteType.Emoji ? .EmojiAutoComplete(terms: terms) : .UserNameAutoComplete(terms: terms)
        ElloProvider.elloRequest(
            endpoint,
            method: .GET,
            success: { (data, responseConfig) in
                if let results = data as? [AutoCompleteResult] {
                    success(results: results, responseConfig: responseConfig)
                }
                else {
                    ElloProvider.unCastableJSONAble(failure)
                }
            },
            failure: failure
        )
    }

}

