//
//  ElloTabBarSpec.swift
//  Ello
//
//  Created by Colin Gray on 10/5/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble
import Nimble_Snapshots


class ElloTabBarSpec: QuickSpec {
    override func spec() {
        describe("ElloTabBar") {
            var subject: ElloTabBar!
            var redDot: UIView!
            let portraitSize = CGSize(width: 320, height: 49)
            let landscapeSize = CGSize(width: 1024, height: 49)

            beforeEach {
                let items = [
                    UITabBarItem.svgItem("sparkles"),
                    UITabBarItem.svgItem("bolt"),
                    UITabBarItem.svgItem("circbig"),
                    UITabBarItem.svgItem("person"),
                    UITabBarItem.svgItem("omni"),
                ]
                subject = ElloTabBar()
                subject.items = items
                redDot = subject.addRedDotAtIndex(1)
                redDot.hidden = false
            }

            context("red dot position") {
                context("portait") {
                    beforeEach {
                        prepareForSnapshot(subject, size: portraitSize)
                    }
                    it("should be in the correct location") {
                        expect(subject).to(haveValidSnapshot())
                    }
                }
                context("landscape") {
                    beforeEach {
                        prepareForSnapshot(subject, size: landscapeSize)
                    }
                    it("should be in the correct location") {
                        expect(subject).to(haveValidSnapshot())
                    }
                }
            }
        }
    }
}
