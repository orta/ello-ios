//
//  S3UploadingServiceSpec.swift
//  Ello
//
//  Created by Colin Gray on 3/6/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Quick
import Nimble


class S3UploadingServiceSpec: QuickSpec {
    var data : NSData?

    override func spec() {
        describe("uploading a file to S3") {
            beforeEach {
                // use the *actual* provider, so we can look for the file on Amazon
                ElloProvider.sharedProvider = ElloProvider.DefaultProvider()
            }
            it("should exist after uploading") {
                let image = UIImage(named: "selected-pixel")
                let uploadService = S3UploadingService()
                uploadService.upload(image,
                    success: { url in
                        selfdata = NSData(contentsOfURL: NSURL(string: url)!)
                    },
                    failure: { error, statusCode in
                    })

                expect(data).toEventually(equal(UIImagePNGRepresentation(image)))
            }
        }
    }
}