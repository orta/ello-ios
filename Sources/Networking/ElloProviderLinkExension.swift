//
//  ElloProviderLinkExension.swift
//  Ello
//
//  Created by Sean on 2/17/16.
//  Copyright © 2016 Ello. All rights reserved.
//

import Foundation
import WebLinking

extension ElloProvider {
    func parseLinks(response: NSHTTPURLResponse?, config: ResponseConfig) -> ResponseConfig {
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
