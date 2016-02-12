//
//  ShareRegionProcessorSpec.swift
//  Ello
//
//  Created by Sean on 2/11/16.
//  Copyright © 2016 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble

class ShareRegionProcessorSpec: QuickSpec {
    override func spec() {
        describe("ShareRegionProcessor") {
            var subject = ShareRegionProcessor()

            beforeEach {
                subject = ShareRegionProcessor()
            }

            describe("prepContent(_:itemPreviews)") {

                it("returns the correct content") {
                    let expectedImage = UIImage()
                    let items = [
                        ExtensionItemPreview(image: nil, imagePath: nil, text: "https://ello.co"),
                        ExtensionItemPreview(image: expectedImage, imagePath: nil, text: nil),
                        ExtensionItemPreview(image: nil, imagePath: nil, text: "hello")
                    ]

                    let contextText = "yo"
                    let prepped = subject.prepContent(contextText, itemPreviews: items)

                    expect(prepped.count) == 4
                    expect(prepped[0] == PostEditingService.PostContentRegion.Text("yo")) == true
                    expect(prepped[1] == PostEditingService.PostContentRegion.Text("https://ello.co")) == true
                    expect(prepped[2] == PostEditingService.PostContentRegion.ImageData(expectedImage, nil, nil)) == true
                    expect(prepped[3] == PostEditingService.PostContentRegion.Text("hello")) == true
                }
            }

            it("filters out duplicate input") {
                let items = [
                    ExtensionItemPreview(image: nil, imagePath: nil, text: "yo")
                ]

                let contextText = "yo"
                let prepped = subject.prepContent(contextText, itemPreviews: items)

                expect(prepped.count) == 1
                expect(prepped[0] == PostEditingService.PostContentRegion.Text("yo")) == true
            }
        }
    }
}
