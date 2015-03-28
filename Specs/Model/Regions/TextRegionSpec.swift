//
//  TextRegionSpec.swift
//  Ello
//
//  Created by Sean on 3/11/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Quick
import Nimble

class TextRegionSpec: QuickSpec {
    override func spec() {

        describe("+fromJSON:") {

            it("parses correctly") {
                let data = stubbedJSONData("text-region", "region")
                let region = TextRegion.fromJSON(data) as! TextRegion

                expect(region.content) == "test text content"

            }
        }

        context("NSCoding") {

            var filePath = ""

            beforeEach {
                filePath = NSFileManager.ElloDocumentsDir().stringByAppendingPathComponent("TextRegionSpec")
            }

            afterEach {
                var error:NSError?
                NSFileManager.defaultManager().removeItemAtPath(filePath, error: &error)
            }

            context("encoding") {

                it("encodes successfully") {
                    let region: TextRegion = stub([:])

                    let wasSuccessfulArchived = NSKeyedArchiver.archiveRootObject(region, toFile: filePath)

                    expect(wasSuccessfulArchived).to(beTrue())
                }
            }

            context("decoding") {

                it("decodes successfully") {
                    let region: TextRegion = stub([
                        "content" : "test-content"
                    ])

                    NSKeyedArchiver.archiveRootObject(region, toFile: filePath)
                    let unArchivedRegion = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as! TextRegion
                    
                    expect(unArchivedRegion).toNot(beNil())
                    expect(unArchivedRegion.version) == 1
                    expect(unArchivedRegion.content) == "test-content"
                }
            }
        }
    }
}
