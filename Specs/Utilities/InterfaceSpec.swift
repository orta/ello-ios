//
//  InterfaceSpec.swift
//  Ello
//
//  Created by Colin Gray on 12/14/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

@testable import Ello
import Quick
import Nimble
import SVGKit


class InterfaceSpec: QuickSpec {
    override func spec() {
        describe("Interface") {
            describe("Image") {
                describe("normalImage") {
                    let normalImages: [Interface.Image] = [
                        .ElloLogo,
                        .Eye,
                        .Heart,
                        .Repost,
                        .Share,
                        .XBox,
                        .Pencil,
                        .Reply,
                        .Flag,
                        .Comments,
                        .Invite,
                        .Sparkles,
                        .Bolt,
                        .Omni,
                        .Person,
                        .CircBig,
                        .NarrationPointer,
                        .Search,
                        .Burger,
                        .Grid,
                        .List,
                        .Reorder,
                        .Camera,
                        .Check,
                        .Arrow,
                        .Link,
                        .BreakLink,
                        .ReplyAll,
                        .BubbleBody,
                        .BubbleTail,
                        .Star,
                        .Question,
                        .X,
                        .Dots,
                        .PlusSmall,
                        .CheckSmall,
                        .AngleBracket,
                        .AudioPlay,
                        .VideoPlay,
                        .ValidationLoading,
                        .ValidationError,
                        .ValidationOK,
                    ]
                    for image in normalImages {
                        it("\(image) should have a normalImage") {
                            expect(image.normalImage).notTo(beNil())
                        }
                    }
                }
                describe("selectedImage") {
                    let selectedImages: [Interface.Image] = [
                        .Eye,
                        .Heart,
                        .Repost,
                        .Share,
                        .XBox,
                        .Pencil,
                        .Reply,
                        .Flag,
                        .Comments,
                        .Invite,
                        .Sparkles,
                        .Bolt,
                        .Omni,
                        .Person,
                        .CircBig,
                        .Search,
                        .Burger,
                        .Grid,
                        .List,
                        .Reorder,
                        .Camera,
                        .Check,
                        .Arrow,
                        .Link,
                        .ReplyAll,
                        .BubbleBody,
                        .Star,
                        .X,
                        .Dots,
                        .PlusSmall,
                        .CheckSmall,
                        .AngleBracket,
                        .ValidationLoading,
                    ]
                    for image in selectedImages {
                        it("\(image) should have a selectedImage") {
                            expect(SVGKSourceLocalFile.internalSourceAnywhereInBundleUsingName("\(image.rawValue)_selected.svg")).toNot(beNil())
                            expect(SVGKImage(named: "\(image.rawValue)_selected.svg").UIImage).toNot(beNil())
                        }
                    }
                }
                describe("whiteImage") {
                    let whiteImages: [Interface.Image] = [
                        .BreakLink,
                        .BubbleBody,
                        .Camera,
                        .Link,
                        .Pencil,
                        .Star,
                        .Arrow,
                        .Comments,
                        .Heart,
                        .PlusSmall,
                        .Invite,
                        .Repost
                    ]
                    for image in whiteImages {
                        it("\(image) should have a whiteImage") {
                            expect(SVGKSourceLocalFile.internalSourceAnywhereInBundleUsingName("\(image.rawValue)_white.svg")).toNot(beNil())
                            expect(SVGKImage(named: "\(image.rawValue)_white.svg").UIImage).toNot(beNil())
                        }
                    }
                }
                describe("disabledImage") {
                    let disabledImages: [Interface.Image] = [
                        .AngleBracket,
                    ]
                    for image in disabledImages {
                        it("\(image) should have a disabledImage") {
                            expect(SVGKSourceLocalFile.internalSourceAnywhereInBundleUsingName("\(image.rawValue)_disabled.svg")).toNot(beNil())
                            expect(SVGKImage(named: "\(image.rawValue)_disabled.svg").UIImage).toNot(beNil())
                        }
                    }
                }
                describe("redImage") {
                    let redImages: [Interface.Image] = [
                        .X,
                    ]
                    for image in redImages {
                        it("\(image) should have a redImage") {
                            expect(SVGKSourceLocalFile.internalSourceAnywhereInBundleUsingName("\(image.rawValue)_red.svg")).toNot(beNil())
                            expect(SVGKImage(named: "\(image.rawValue)_red.svg").UIImage).toNot(beNil())
                        }
                    }
                }
            }
        }
    }
}
