//
//  StreamTextCellHTML.swift
//  Ello
//
//  Created by Sean Dougherty on 12/16/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Foundation

struct StreamTextCellHTML {

    static var indexFile:String?

    static func indexFileAsString() -> String {
        if let indexFile = StreamTextCellHTML.indexFile {
            return indexFile
        }
        else {
            let indexHTML = NSBundle.mainBundle().pathForResource("index", ofType: "html", inDirectory: "www")!
            let indexURL = NSURL(string:indexHTML)!
            var req = NSURLRequest(URL:indexURL)

            var error:NSError?
            let indexAsText = NSString(contentsOfFile: indexHTML, encoding: NSUTF8StringEncoding, error: &error)
            if error == nil && indexAsText != nil {
                StreamTextCellHTML.indexFile = indexAsText
            }
            else {
                StreamTextCellHTML.indexFile = ""
            }
            return StreamTextCellHTML.indexFile!
        }
    }

    static func postHTML(string:String) -> String {
        return StreamTextCellHTML.indexFileAsString().stringByReplacingOccurrencesOfString("{{post-content}}", withString: string)
    }

}