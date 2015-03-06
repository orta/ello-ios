//
//  MultipartRequestBuilderSpec.swift
//  Ello
//
//  Created by Colin Gray on 3/6/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Quick
import Nimble


class MultipartRequestBuilderSpec: QuickSpec {
    override func spec() {
        let url = NSURL(string: "http://ello.co")!
        var request = NSURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: 10.0)
        var content = ""
        var builder : MultipartRequestBuilder!

        describe("building a multipart request") {
            beforeEach {
                builder = MultipartRequestBuilder(url: url, capacity: 100)
                builder.addParam("foo", value: "bar")
                builder.addParam("baz", value: "a\nb\nc")

                request = builder.buildRequest()
                content = NSString(data: request.HTTPBody!, encoding: NSUTF8StringEncoding) ?? ""
            }
            it("can build a multipart request") {
                let boundaryConstant = builder.boundaryConstant
                var expected = ""
                expected += "--\(boundaryConstant)\r\n"
                expected += "Content-Disposition: form-data; name=\"foo\"\r\n"
                expected += "\r\n"
                expected += "bar\r\n"
                expected += "--\(boundaryConstant)\r\n"
                expected += "Content-Disposition: form-data; name=\"baz\"\r\n"
                expected += "\r\n"
                expected += "a\n" + "b\n" + "c" + "\r\n"
                expected += "--\(boundaryConstant)--\r\n"

                expect(content).to(equal(expected))
            }
        }
    }
}