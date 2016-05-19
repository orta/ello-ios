//
//  MultipartRequestBuilder.swift
//  Ello
//
//  Created by Colin Gray on 3/4/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

public class MultipartRequestBuilder {
    public let boundaryConstant: String
    private var body: NSMutableData
    private var requestIsBuilt: Bool = false
    private var request: NSMutableURLRequest

    public init(url: NSURL, capacity: Int = 0) {
        let cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        boundaryConstant = "Boundary-7MA4YWxkTLLu0UIW" // This should be randomly-generated.

        request = NSMutableURLRequest(URL: url, cachePolicy: cachePolicy, timeoutInterval: 10.0)
        request.HTTPMethod = "POST"

        request.setValue("multipart/form-data; boundary=\(boundaryConstant)", forHTTPHeaderField: "Content-Type")

        body = NSMutableData(capacity: capacity)!
    }

    public func addParam(name: String, value: String) {
        if requestIsBuilt {
            fatalError("Cannot add parameters after request has been built")
        }

        body.appendData("--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData("Content-Disposition: form-data; name=\"\(name)\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData("\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData(value.dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData("\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
    }

    func addFile(name: String, filename: String, data: NSData, contentType: String) {
        if requestIsBuilt {
            fatalError("Cannot add parameters after request has been built")
        }

        body.appendData("--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(filename)\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData("Content-Type: \(contentType)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData("\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData(data)
        body.appendData("\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
    }

    public func buildRequest() -> NSMutableURLRequest {
        requestIsBuilt = true
        body.appendData("--\(boundaryConstant)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        request.HTTPBody = body

        return request
    }

}