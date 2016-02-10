//
//  AutoCompleteService.swift
//  Ello
//
//  Created by Sean on 6/30/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Alamofire
import SwiftyJSON

public typealias AutoCompleteServiceSuccessCompletion = (results: [AutoCompleteResult], responseConfig: ResponseConfig) -> ()

public struct AutoCompleteService {

    public init(){}

    public func loadUsernameResults(
        terms: String,
        success: AutoCompleteServiceSuccessCompletion,
        failure: ElloFailureCompletion)
    {
        ElloProvider.shared.elloRequest(
            .UserNameAutoComplete(terms: terms),
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

    public func loadEmojiResults(text: String) -> [AutoCompleteResult] {
        let emojiName: String
        if text[text.startIndex] == ":" {
            emojiName = text.substringFromIndex(text.startIndex.advancedBy(1))
        }
        else {
            emojiName = text
        }
        return AutoCompleteService.emojis.filter {
            ":\($0):".contains(emojiName)
        }.map {
            AutoCompleteResult(name: $0, url: "https://ello.co/images/emoji/\($0).png")
        }
    }

    static var emojis: [String] = []
    static func loadEmojiJSON(defaultJSON: String) {
        let data = stubbedData(defaultJSON)
        let json: JSON
        do {
            json = try JSON(data: data)
        }
        catch {
            json = JSON("")
        }

        if let emojis = json["emojis"].object as? [String]
        {
            self.emojis = emojis
        }

        Alamofire.request(.GET, "\(ElloURI.baseURL)/emojis.json")
            .responseJSON { response in
                if let JSON = response.result.value,
                    emojis = JSON["emojis"] as? [String]
                {
                    self.emojis = emojis
                }
            }
    }

}

