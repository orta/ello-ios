//
//  ShareAttachmentProcessorSpec.swift
//  Ello
//
//  Created by Sean on 2/10/16.
//  Copyright © 2016 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble

class ShareAttachmentProcessorSpec: QuickSpec {
    override func spec() {

        describe("ShareAttachmentProcessor") {

            var itemPreviews: [ExtensionItemPreview] = []

            afterEach {
                itemPreviews = []
            }

            describe("preview(_:callback)") {

                var fileURL: NSURL?
                if let url = NSURL(string: NSTemporaryDirectory()) {
                    fileURL = url.URLByAppendingPathComponent("ShareAttachmentProcessorSpec")
                }

                afterEach {
                    do { try NSFileManager.defaultManager().removeItemAtPath(fileURL?.path ?? "") }
                    catch { }
                }

                it("loads url items") {
                    let extensionItem = NSExtensionItem()
                    let image = UIImage(named: "specs-avatar", inBundle: NSBundle(forClass: self.dynamicType), compatibleWithTraitCollection: nil)!
                    let imageAsData = UIImagePNGRepresentation(image)
                    if let fileURL = fileURL {
                        imageAsData?.writeToFile(fileURL.path!, atomically: true)
                    }

                    extensionItem.attachments = [
                        NSItemProvider(item: NSURL(string: "https://ello.co"), typeIdentifier: String(kUTTypeURL)),
                        NSItemProvider(item: "hello", typeIdentifier: String(kUTTypeText)),
                        NSItemProvider(item: fileURL, typeIdentifier: String(kUTTypeImage))
                    ]

                    let urlPreview = ExtensionItemPreview(text: "https://ello.co")
                    let textPreview = ExtensionItemPreview(text: "hello")

                    waitUntil(timeout: 30) { done in
                        ShareAttachmentProcessor.preview(extensionItem) { previews in
                            itemPreviews = previews
                            expect(itemPreviews.count) == 3
                            expect(itemPreviews[0] == urlPreview).to(beTrue())
                            expect(itemPreviews[1] == textPreview).to(beTrue())
                            expect(itemPreviews[2].image).notTo(beNil())
                            done()
                        }
                    }
                }

                it("filters out duplicate url items") {
                    let extensionItem = NSExtensionItem()

                    extensionItem.attachments = [
                        NSItemProvider(item: NSURL(string: "https://ello.co"), typeIdentifier: String(kUTTypeURL)),
                        NSItemProvider(item: "https://ello.co", typeIdentifier: String(kUTTypeText))
                    ]

                    let urlPreview = ExtensionItemPreview(text: "https://ello.co")

                    waitUntil(timeout: 30) { done in
                        ShareAttachmentProcessor.preview(extensionItem) { previews in
                            itemPreviews = previews
                            expect(itemPreviews[0] == urlPreview).to(beTrue())
                            expect(itemPreviews.count) == 1
                            done()
                        }
                    }
                }
            }

            describe("hasContent(_:)") {
                context("has something to share") {
                    let extensionItem = NSExtensionItem()

                    extensionItem.attachments = [
                        NSItemProvider(item: NSURL(string: "https://ello.co"), typeIdentifier: String(kUTTypeURL)),
                        NSItemProvider(item: "https://ello.co", typeIdentifier: String(kUTTypeText))
                    ]

                    it("returns true if content text is present and extension item is nil") {
                        expect(ShareAttachmentProcessor.hasContent("content", extensionItem: nil)) == true
                    }

                    it("returns true if content text is nil and extension item is present") {
                        expect(ShareAttachmentProcessor.hasContent(nil, extensionItem: extensionItem)) == true
                    }

                    it("returns true if content text is present and extension item is present") {
                        expect(ShareAttachmentProcessor.hasContent("content", extensionItem: extensionItem)) == true
                    }

                }

                context("has nothing to share") {

                    it("returns false if nothing is present") {
                        expect(ShareAttachmentProcessor.hasContent(nil, extensionItem: nil)) == false
                    }
                }
            }
        }
    }
}
