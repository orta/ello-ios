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


class ElloTabBarSpec: QuickSpec {
    override func spec() {
        describe("ElloTabBar") {
            var subject: ElloTabBar!
            var redDot: UIView!
            let portraitFrame = CGRect(x: 0, y: 0, width: 320, height: 480)
            let landscapeFrame = CGRect(x: 0, y: 0, width: 480, height: 320)

            context("red dot position") {
                context("portait") {
                    beforeEach {
                        subject = ElloTabBar()
                        subject.frame = portraitFrame
                        let items = [
                            UITabBarItem(tabBarSystemItem: .More, tag: 0),
                            UITabBarItem(tabBarSystemItem: .Favorites, tag: 0),
                            UITabBarItem(tabBarSystemItem: .Featured, tag: 0),
                        ]
                        subject.items = items
                        redDot = subject.addRedDotAtIndex(1)

                        self.showView(subject)
                    }
                    it("should be in the correct location") {
                        let expected = CGRect(x: 135.5, y: 11, width: 6, height: 6)
                        expect(redDot.frame.origin.x) == expected.origin.x
                        expect(redDot.frame.origin.y) == expected.origin.y
                        expect(redDot.frame.size.width) == expected.size.width
                        expect(redDot.frame.size.height) == expected.size.height
                    }
                }
                context("landscape") {
                    beforeEach {
                        subject = ElloTabBar()
                        subject.frame = landscapeFrame
                        let items = [
                            UITabBarItem(tabBarSystemItem: .More, tag: 0),
                            UITabBarItem(tabBarSystemItem: .Favorites, tag: 0),
                            UITabBarItem(tabBarSystemItem: .Featured, tag: 0),
                        ]
                        subject.items = items
                        redDot = subject.addRedDotAtIndex(1)

                        self.showView(subject)
                    }
                    it("should be in the correct location") {
                        let expected = CGRect(x: 215.5, y: 11, width: 6, height: 6)
                        expect(redDot.frame.origin.x) == expected.origin.x
                        expect(redDot.frame.origin.y) == expected.origin.y
                        expect(redDot.frame.size.width) == expected.size.width
                        expect(redDot.frame.size.height) == expected.size.height
                    }
                }
            }
        }
    }
}
