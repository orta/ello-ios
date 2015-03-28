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
                let asset = Asset.fromJSON(data) as! Asset

                expect(asset.assetId) == "5381"

                let optimized = asset.optimized!

                expect(optimized.url!.absoluteString) == "https://example.com/5381/optimized.jpg"
                expect(optimized.size) == 728689
                expect(optimized.imageType) == "image/jpeg"
                expect(optimized.width) == 2560
                expect(optimized.height) == 1094

                let smallScreen = asset.smallScreen!

                expect(smallScreen.url!.absoluteString) == "https://example.com/5381/small_screen.jpg"
                expect(smallScreen.size) == 58160
                expect(smallScreen.imageType) == "image/jpeg"
                expect(smallScreen.width) == 640
                expect(smallScreen.height) == 274

                let ldpi = asset.ldpi!

                expect(ldpi.url!.absoluteString) == "https://example.com/5381/ldpi.jpg"
                expect(ldpi.size) == 4437
                expect(ldpi.imageType) == "image/jpeg"
                expect(ldpi.width) == 150
                expect(ldpi.height) == 64

                let mdpi = asset.mdpi!

                expect(mdpi.url!.absoluteString) == "https://example.com/5381/mdpi.jpg"
                expect(mdpi.size) == 21813
                expect(mdpi.imageType) == "image/jpeg"
                expect(mdpi.width) == 375
                expect(mdpi.height) == 160

                let hdpi = asset.hdpi!

                expect(hdpi.url!.absoluteString) == "https://example.com/5381/hdpi.jpg"
                expect(hdpi.size) == 77464
                expect(hdpi.imageType) == "image/jpeg"
                expect(hdpi.width) == 750
                expect(hdpi.height) == 321

                let xhdpi = asset.xhdpi!

                expect(xhdpi.url!.absoluteString) == "https://example.com/5381/xhdpi.jpg"
                expect(xhdpi.size) == 274363
                expect(xhdpi.imageType) == "image/jpeg"
                expect(xhdpi.width) == 1500
                expect(xhdpi.height) == 641

                let xxhdpi = asset.xxhdpi!

                expect(xxhdpi.url!.absoluteString) == "https://example.com/5381/xxhdpi.jpg"
                expect(xxhdpi.size) == 728689
                expect(xxhdpi.imageType) == "image/jpeg"
                expect(xxhdpi.width) == 2560
                expect(xxhdpi.height) == 1094

                let xxxhdpi = asset.xxxhdpi!

                expect(xxxhdpi.url!.absoluteString) == "https://example.com/5381/xxxhdpi.jpg"
                expect(xxxhdpi.size) == 728687
                expect(xxxhdpi.imageType) == "image/jpeg"
                expect(xxxhdpi.width) == 2560
                expect(xxxhdpi.height) == 1094
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
                    let asset: Asset = stub([:])

                    let wasSuccessfulArchived = NSKeyedArchiver.archiveRootObject(asset, toFile: filePath)

                    expect(wasSuccessfulArchived).to(beTrue())
                }
            }

            context("decoding") {

                it("decodes successfully") {

                    let optimized: ImageAttachment = stub([
                        "url" : NSURL(string: "http://www.example1.com")!,
                        "height" : 10,
                        "width" : 20,
                        "imageType" : "jpeg",
                        "size" : 111111
                    ])

                    let smallScreen: ImageAttachment = stub([
                        "url" : NSURL(string: "http://www.example2.com")!,
                        "height" : 20,
                        "width" : 30,
                        "imageType" : "jpeg",
                        "size" : 222222
                    ])

                    let ldpi: ImageAttachment = stub([
                        "url" : NSURL(string: "http://www.example3.com")!,
                        "height" : 30,
                        "width" : 40,
                        "imageType" : "jpeg",
                        "size" : 333333
                    ])

                    let mdpi: ImageAttachment = stub([
                        "url" : NSURL(string: "http://www.example4.com")!,
                        "height" : 40,
                        "width" : 50,
                        "imageType" : "jpeg",
                        "size" : 444444
                    ])

                    let hdpi: ImageAttachment = stub([
                        "url" : NSURL(string: "http://www.example5.com")!,
                        "height" : 50,
                        "width" : 60,
                        "imageType" : "jpeg",
                        "size" : 555555
                    ])

                    let xhdpi: ImageAttachment = stub([
                        "url" : NSURL(string: "http://www.example6.com")!,
                        "height" : 60,
                        "width" : 70,
                        "imageType" : "jpeg",
                        "size" : 666666
                    ])

                    let xxhdpi: ImageAttachment = stub([
                        "url" : NSURL(string: "http://www.example7.com")!,
                        "height" : 70,
                        "width" : 80,
                        "imageType" : "png",
                        "size" : 777777
                    ])

                    let xxxhdpi: ImageAttachment = stub([
                        "url" : NSURL(string: "http://www.example8.com")!,
                        "height" : 80,
                        "width" : 90,
                        "imageType" : "jpeg",
                        "size" : 888888
                    ])

                    let asset: Asset = stub([
                        "assetId" : "5698",
                        "optimized" : optimized,
                        "smallScreen" : smallScreen,
                        "ldpi" : ldpi,
                        "mdpi" : mdpi,
                        "hdpi" : hdpi,
                        "xhdpi" : xhdpi,
                        "xxhdpi" : xxhdpi,
                        "xxxhdpi" : xxxhdpi
                    ])

                    NSKeyedArchiver.archiveRootObject(asset, toFile: filePath)
                    let unArchivedAsset = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as! Asset

                    expect(unArchivedAsset).toNot(beNil())
                    expect(unArchivedAsset.version) == 1

                    expect(unArchivedAsset.assetId) == "5698"

                    let unArchivedOptimized = unArchivedAsset.optimized!

                    expect(unArchivedOptimized.url!.absoluteString) == "http://www.example1.com"
                    expect(unArchivedOptimized.width) == 20
                    expect(unArchivedOptimized.height) == 10
                    expect(unArchivedOptimized.size) == 111111
                    expect(unArchivedOptimized.imageType) == "jpeg"

                    let unArchivedSmallScreen = unArchivedAsset.smallScreen!

                    expect(unArchivedSmallScreen.url!.absoluteString) == "http://www.example2.com"
                    expect(unArchivedSmallScreen.width) == 30
                    expect(unArchivedSmallScreen.height) == 20
                    expect(unArchivedSmallScreen.size) == 222222
                    expect(unArchivedSmallScreen.imageType) == "jpeg"

                    let unArchivedldpi = unArchivedAsset.ldpi!

                    expect(unArchivedldpi.url!.absoluteString) == "http://www.example3.com"
                    expect(unArchivedldpi.width) == 40
                    expect(unArchivedldpi.height) == 30
                    expect(unArchivedldpi.size) == 333333
                    expect(unArchivedldpi.imageType) == "jpeg"

                    let unArchivedmdpi = unArchivedAsset.mdpi!

                    expect(unArchivedmdpi.url!.absoluteString) == "http://www.example4.com"
                    expect(unArchivedmdpi.width) == 50
                    expect(unArchivedmdpi.height) == 40
                    expect(unArchivedmdpi.size) == 444444
                    expect(unArchivedmdpi.imageType) == "jpeg"

                    let unArchivedhdpi = unArchivedAsset.hdpi!

                    expect(unArchivedhdpi.url!.absoluteString) == "http://www.example5.com"
                    expect(unArchivedhdpi.width) == 60
                    expect(unArchivedhdpi.height) == 50
                    expect(unArchivedhdpi.size) == 555555
                    expect(unArchivedhdpi.imageType) == "jpeg"

                    let unArchivedxhdpi = unArchivedAsset.xhdpi!

                    expect(unArchivedxhdpi.url!.absoluteString) == "http://www.example6.com"
                    expect(unArchivedxhdpi.width) == 70
                    expect(unArchivedxhdpi.height) == 60
                    expect(unArchivedxhdpi.size) == 666666
                    expect(unArchivedxhdpi.imageType) == "jpeg"

                    let unArchivedxxhdpi = unArchivedAsset.xxhdpi!

                    expect(unArchivedxxhdpi.url!.absoluteString) == "http://www.example7.com"
                    expect(unArchivedxxhdpi.width) == 80
                    expect(unArchivedxxhdpi.height) == 70
                    expect(unArchivedxxhdpi.size) == 777777
                    expect(unArchivedxxhdpi.imageType) == "png"

                    let unArchivedxxxhdpi = unArchivedAsset.xxxhdpi!

                    expect(unArchivedxxxhdpi.url!.absoluteString) == "http://www.example8.com"
                    expect(unArchivedxxxhdpi.width) == 90
                    expect(unArchivedxxxhdpi.height) == 80
                    expect(unArchivedxxxhdpi.size) == 888888
                    expect(unArchivedxxxhdpi.imageType) == "jpeg"

                }
            }
        }
    }
}
