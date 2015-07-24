//
//  StreamImageViewerSpec.swift
//  Ello
//
//  Created by Sean on 7/24/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble
import Moya
import JTSImageViewController
import FLAnimatedImage

class StreamImageViewerSpec: QuickSpec {

    override func spec() {

        describe("StreamImageViewer") {

            let presentingVC = StreamViewController.instantiateFromStoryboard()
            var subject: StreamImageViewer!

            beforeEach {
                subject = StreamImageViewer(presentingController: presentingVC)
            }

            describe("imageTapped(_:cell:)") {

                it("configures AppDelegate to allow rotation") {
                    let image = FLAnimatedImageView()
                    subject.imageTapped(image, imageURL: NSURL(string: "http://www.example.com/image.jpg"))

                    expect(AppDelegate.restrictRotation) == false
                }
            }

            context("JTSImageViewControllerOptionsDelegate") {

                describe("alphaForBackgroundDimmingOverlayInImageViewer(_:)") {

                    it("returns 1.0") {
                        expect(subject.alphaForBackgroundDimmingOverlayInImageViewer(JTSImageViewController())) == 1.0
                    }
                }
            }

            context("JTSImageViewControllerDismissalDelegate") {

                describe("imageViewerWillDismiss(_:)") {

                    it("configures AppDelegate to prevent rotation") {
                        subject.imageViewerWillDismiss(JTSImageViewController())

                        expect(AppDelegate.restrictRotation) == true
                    }
                }
            }
        }
    }
}
