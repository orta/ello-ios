//
//  ImageAttachmentSpec.swift
//  Ello
//
//  Created by Sean on 3/11/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Quick
import Nimble

class ImageAttachmentSpec: QuickSpec {
    override func spec() {

        context("NSCoding") {

            var filePath = ""

            beforeEach {
                filePath = NSFileManager.ElloDocumentsDir().stringByAppendingPathComponent("ImageAttachmentSpec")
            }

            afterEach {
                var error:NSError?
                NSFileManager.defaultManager().removeItemAtPath(filePath, error: &error)
            }

            context("encoding") {

                it("encodes successfully") {
                    let imageAttachment: ImageAttachment = stub([:])

                    let wasSuccessfulArchived = NSKeyedArchiver.archiveRootObject(imageAttachment, toFile: filePath)

                    expect(wasSuccessfulArchived).to(beTrue())
                }
            }

            context("decoding") {

                it("decodes successfully") {
                    let imageAttachment: ImageAttachment = stub([
                        "url" : NSURL(string: "http://www.example12.com")!,
                        "height" : 456,
                        "width" : 110,
                        "imageType" : "png",
                        "size" : 78787
                    ])

                    NSKeyedArchiver.archiveRootObject(imageAttachment, toFile: filePath)
                    let unArchivedAttachment = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as! ImageAttachment

                    expect(unArchivedAttachment).toNot(beNil())
                    expect(unArchivedAttachment.version) == 1
                    expect(unArchivedAttachment.url!.absoluteString) == "http://www.example12.com"
                    expect(unArchivedAttachment.height) == 456
                    expect(unArchivedAttachment.width) == 110
                    expect(unArchivedAttachment.size) == 78787
                    expect(unArchivedAttachment.imageType) == "png"
                }
            }
        }
    }
}
