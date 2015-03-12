//
//  AssetSpec.swift
//  Ello
//
//  Created by Sean on 3/11/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Quick
import Nimble

class AssetSpec: QuickSpec {
    override func spec() {

        describe("+fromJSON:") {

            it("parses correctly") {
                let data = stubbedJSONData("asset", "assets")
                let asset = Asset.fromJSON(data) as Asset

                expect(asset.assetId) == "5381"

                let hdpi = asset.hdpi!

                expect(hdpi.url!.absoluteString) == "https://example.com/5381/hdpi.jpg"
                expect(hdpi.size) == 77464
                expect(hdpi.imageType) == "image/jpeg"
                expect(hdpi.width) == 750
                expect(hdpi.height) == 321

                let xxhdpi = asset.xxhdpi!

                expect(xxhdpi.url!.absoluteString) == "https://example.com/5381/xxhdpi.jpg"
                expect(xxhdpi.size) == 728689
                expect(xxhdpi.imageType) == "image/jpeg"
                expect(xxhdpi.width) == 2560
                expect(xxhdpi.height) == 1094
            }
        }

        context("NSCoding") {

            var filePath = ""

            beforeEach {
                filePath = NSFileManager.ElloDocumentsDir().stringByAppendingPathComponent("AssetSpec")
            }

            afterEach {
                var error:NSError?
                NSFileManager.defaultManager().removeItemAtPath(filePath, error: &error)
            }

            context("encoding") {

                it("encodes successfully") {
                    let asset: Asset = stub(nil)

                    let wasSuccessfulArchived = NSKeyedArchiver.archiveRootObject(asset, toFile: filePath)

                    expect(wasSuccessfulArchived).to(beTrue())
                }
            }

            context("decoding") {

                it("decodes successfully") {

                    let hdpi: ImageAttachment = stub([
                        "url" : NSURL(string: "http://www.example.com")!,
                        "height" : 35,
                        "width" : 45,
                        "imageType" : "jpeg",
                        "size" : 445566
                    ])

                    let xxhdpi: ImageAttachment = stub([
                        "url" : NSURL(string: "http://www.example2.com")!,
                        "height" : 99,
                        "width" : 10,
                        "imageType" : "png",
                        "size" : 986896
                    ])

                    let asset: Asset = stub([
                        "assetId" : "5698",
                        "hdpi" : hdpi,
                        "xxhdpi" : xxhdpi
                    ])

                    NSKeyedArchiver.archiveRootObject(asset, toFile: filePath)
                    let unArchivedAsset = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as Asset

                    expect(unArchivedAsset).toNot(beNil())
                    expect(unArchivedAsset.version) == 1

                    expect(unArchivedAsset.assetId) == "5698"

                    let unArchivedhdpi = unArchivedAsset.hdpi!

                    expect(unArchivedhdpi.url!.absoluteString) == "http://www.example.com"
                    expect(unArchivedhdpi.width) == 45
                    expect(unArchivedhdpi.height) == 35
                    expect(unArchivedhdpi.size) == 445566
                    expect(unArchivedhdpi.imageType) == "jpeg"

                    let unArchivedxxhdpi = unArchivedAsset.xxhdpi!

                    expect(unArchivedxxhdpi.url!.absoluteString) == "http://www.example2.com"
                    expect(unArchivedxxhdpi.width) == 10
                    expect(unArchivedxxhdpi.height) == 99
                    expect(unArchivedxxhdpi.size) == 986896
                    expect(unArchivedxxhdpi.imageType) == "png"

                }
            }
        }
    }
}
