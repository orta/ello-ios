//
//  StreamImageCellPresenterSpec.swift
//  Ello
//
//  Created by Sean on 5/21/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble

class StreamImageCellPresenterSpec: QuickSpec {
    override func spec() {

        beforeEach {
            supressRequestsTo("www.example.com")
        }

        describe("configure") {

            context("column number differences") {
                let post: Post = stub([:])
                let imageRegion: ImageRegion = stub([:])

                let cell: StreamImageCell = StreamImageCell.loadFromNib()
                let item: StreamCellItem = StreamCellItem(jsonable: post, type: .Image, data: imageRegion, oneColumnCellHeight: 0, multiColumnCellHeight: 0, isFullWidth: false)

                context("single column") {

                    it("configures fail constraints correctly") {
                        StreamImageCellPresenter.configure(cell, streamCellItem: item, streamKind: .Friend, indexPath: NSIndexPath(forItem: 0, inSection: 0), currentUser: nil)

                        expect(cell.failWidthConstraint.constant) == 140
                        expect(cell.failHeightConstraint.constant) == 160
                    }
                }

                context("multiple columns") {

                    it("configures fail constraints correctly") {
                        StreamImageCellPresenter.configure(cell, streamCellItem: item, streamKind: .Noise, indexPath: NSIndexPath(forItem: 0, inSection: 0), currentUser: nil)

                        expect(cell.failWidthConstraint.constant) == 70
                        expect(cell.failHeightConstraint.constant) == 80
                    }
                }
            }

            context("no asset") {

                context("image is a gif") {

                    it("configures a stream image cell") {
                        let post: Post = stub(["id" : "768"])

                        let imageRegion: ImageRegion = stub([
                            "alt" : "some-altness",
                            "url" : NSURL(string: "http://www.example.com/image.gif")!
                        ])

                        let cell: StreamImageCell = StreamImageCell.loadFromNib()
                        let item: StreamCellItem = StreamCellItem(jsonable: post, type: .Image, data: imageRegion, oneColumnCellHeight: 0, multiColumnCellHeight: 0, isFullWidth: false)

                        StreamImageCellPresenter.configure(cell, streamCellItem: item, streamKind: .Friend, indexPath: NSIndexPath(forItem: 0, inSection: 0), currentUser: nil)

                        expect(cell.isGif) == true
                        expect(cell.isLargeImage) == false
                        expect(cell.largeImagePlayButton?.hidden) == true
                        expect(cell.presentedImageUrl).to(beNil())
                    }
                }

                context("image is not a gif") {

                    it("configures a stream image cell") {
                        let post: Post = stub(["id" : "768"])

                        let imageRegion: ImageRegion = stub([
                            "alt" : "some-altness",
                            "url" : NSURL(string: "http://www.example.com/image.jpg")!
                        ])

                        let cell: StreamImageCell = StreamImageCell.loadFromNib()
                        let item: StreamCellItem = StreamCellItem(jsonable: post, type: .Image, data: imageRegion, oneColumnCellHeight: 0, multiColumnCellHeight: 0, isFullWidth: false)

                        StreamImageCellPresenter.configure(cell, streamCellItem: item, streamKind: .Friend, indexPath: NSIndexPath(forItem: 0, inSection: 0), currentUser: nil)

                        expect(cell.isGif) == false
                        expect(cell.isLargeImage) == false
                        expect(cell.largeImagePlayButton?.hidden) == true
                        expect(cell.presentedImageUrl).to(beNil())
                    }

                }
            }

            context("has asset") {

                context("not a gif") {

                    it("configures a stream image cell") {
                        let post: Post = stub(["id" : "768"])

                        let optimized: Attachment = stub([
                            "url" : NSURL(string: "http://www.example.com/optimized.jpg")!,
                            "type" : "image/jpg",
                            "size" : 9999999
                        ])

                        let hdpi: Attachment = stub([
                            "url" : NSURL(string: "http://www.example.com/hdpi.jpg")!,
                            "type" : "image/jpg",
                            "size" : 445566
                        ])

                        let asset: Asset = stub([
                            "id" : "qwerty",
                            "hdpi" : hdpi,
                            "optimized" : optimized
                            ])

                        let imageRegion: ImageRegion = stub([
                            "asset" : asset,
                            "alt" : "some-altness",
                            "url" : NSURL(string: "http://www.example.com/image.jpg")!
                            ])

                        let cell: StreamImageCell = StreamImageCell.loadFromNib()
                        let item: StreamCellItem = StreamCellItem(jsonable: post, type: .Image, data: imageRegion, oneColumnCellHeight: 0, multiColumnCellHeight: 0, isFullWidth: false)

                        StreamImageCellPresenter.configure(cell, streamCellItem: item, streamKind: .Friend, indexPath: NSIndexPath(forItem: 0, inSection: 0), currentUser: nil)

                        expect(cell.isGif) == false
                        expect(cell.isLargeImage) == false
                        expect(cell.largeImagePlayButton?.hidden) == true
                        expect(cell.presentedImageUrl).to(beNil())
                    }
                }

                context("large filesize gif") {

                    it("configures a stream image cell") {
                        let post: Post = stub(["id" : "768"])

                        let optimized: Attachment = stub([
                            "url" : NSURL(string: "http://www.example.com/optimized.gif")!,
                            "type" : "image/gif",
                            "size" : 9999999
                            ])

                        let hdpi: Attachment = stub([
                            "url" : NSURL(string: "http://www.example.com/hdpi.gif")!,
                            "type" : "image/gif",
                            "size" : 445566
                            ])

                        let asset: Asset = stub([
                            "id" : "qwerty",
                            "hdpi" : hdpi,
                            "optimized" : optimized
                            ])

                        let imageRegion: ImageRegion = stub([
                            "asset" : asset,
                            "alt" : "some-altness",
                            "url" : NSURL(string: "http://www.example.com/image.gif")!
                            ])

                        let cell: StreamImageCell = StreamImageCell.loadFromNib()
                        let item: StreamCellItem = StreamCellItem(jsonable: post, type: .Image, data: imageRegion, oneColumnCellHeight: 0, multiColumnCellHeight: 0, isFullWidth: false)

                        StreamImageCellPresenter.configure(cell, streamCellItem: item, streamKind: .Friend, indexPath: NSIndexPath(forItem: 0, inSection: 0), currentUser: nil)

                        expect(cell.isGif) == true
                        expect(cell.isLargeImage) == true
                        expect(cell.largeImagePlayButton?.hidden) == false
                        expect(cell.presentedImageUrl).notTo(beNil())
                    }
                }

                context("small filesize gif") {

                    it("configures a stream image cell") {
                        let post: Post = stub(["id" : "768"])

                        let optimized: Attachment = stub([
                            "url" : NSURL(string: "http://www.example.com/optimized.gif")!,
                            "type" : "image/gif",
                            "size" : 445566
                            ])

                        let hdpi: Attachment = stub([
                            "url" : NSURL(string: "http://www.example.com/hdpi.gif")!,
                            "type" : "image/gif",
                            "size" : 445566
                            ])

                        let asset: Asset = stub([
                            "id" : "qwerty",
                            "hdpi" : hdpi,
                            "optimized" : optimized
                            ])

                        let imageRegion: ImageRegion = stub([
                            "asset" : asset,
                            "alt" : "some-altness",
                            "url" : NSURL(string: "http://www.example.com/image.gif")!
                            ])

                        let cell: StreamImageCell = StreamImageCell.loadFromNib()
                        let item: StreamCellItem = StreamCellItem(jsonable: post, type: .Image, data: imageRegion, oneColumnCellHeight: 0, multiColumnCellHeight: 0, isFullWidth: false)
                        
                        StreamImageCellPresenter.configure(cell, streamCellItem: item, streamKind: .Friend, indexPath: NSIndexPath(forItem: 0, inSection: 0), currentUser: nil)
                        
                        expect(cell.isGif) == true
                        expect(cell.isLargeImage) == false
                        expect(cell.largeImagePlayButton?.hidden) == true
                        expect(cell.presentedImageUrl).to(beNil())
                    }
                }
            }
        }
    }
}
