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
        fdescribe("ElloTabBar") {
            var subject: ElloTabBar!
            var redDot: UIView!
            let portraitFrame = CGRect(x: 0, y: 0, width: 320, height: 44)
            let landscapeFrame = CGRect(x: 0, y: 0, width: 1024, height: 44)

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
                        subject.frame = portraitFrame
                        self.showView(subject)
                    }
                    it("should be in the correct location") {
                        expect(subject).to(haveValidSnapshot())
                    }
                }
                context("landscape") {
                    beforeEach {
                        subject.frame = landscapeFrame
                        self.showView(subject)
                    }
                    it("should be in the correct location") {
                        expect(subject).to(haveValidSnapshot())
                    }
                }
            }
        }
    }
}
