//
//  UnknownRegionSpec.swift
//  Ello
//
//  Created by Sean on 3/11/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Quick
import Nimble

class UnknownRegionSpec: QuickSpec {
    override func spec() {

        context("NSCoding") {

            var filePath = ""

            beforeEach {
                filePath = NSFileManager.ElloDocumentsDir().stringByAppendingPathComponent("UnknownRegionSpec")
            }

            afterEach {
                var error:NSError?
                NSFileManager.defaultManager().removeItemAtPath(filePath, error: &error)
            }

            context("encoding") {

                it("encodes successfully") {
                    let region: UnknownRegion = stub([:])

                    let wasSuccessfulArchived = NSKeyedArchiver.archiveRootObject(region, toFile: filePath)

                    expect(wasSuccessfulArchived).to(beTrue())
                }
            }

            context("decoding") {

                it("decodes successfully") {

                    let region: UnknownRegion = stub([:])

                    NSKeyedArchiver.archiveRootObject(region, toFile: filePath)
                    let unArchivedRegion = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as UnknownRegion

                    expect(unArchivedRegion).toNot(beNil())
                    expect(unArchivedRegion.version) == 1
                }
            }
        }
    }
}
