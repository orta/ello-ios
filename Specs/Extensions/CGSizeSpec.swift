//
//  CGSizeSpec.swift
//  Ello
//
//  Created by Colin Gray on 7/21/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Quick
import Nimble
import Ello


class CGSizeSpec: QuickSpec {
    override func spec() {
        context("scaledSize(_:)") {
            describe("should ignore sizes that are already small enough") {
                it("CGSize(width: 100, height: 100).scaledSize(CGSize(width: 1000, height: 1000))") {
                    let initial = CGSize(width: 100, height: 100)
                    let maxSize = CGSize(width: 1000, height: 1000)
                    let subject = initial.scaledSize(maxSize)
                    expect(subject.width) == initial.width
                    expect(subject.height) == initial.height
                }
                it("CGSize(width: 100, height: 100).scaledSize(CGSize(width: 100, height: 1000))") {
                    let initial = CGSize(width: 100, height: 100)
                    let maxSize = CGSize(width: 100, height: 1000)
                    let subject = initial.scaledSize(maxSize)
                    expect(subject.width) == initial.width
                    expect(subject.height) == initial.height
                }
                it("CGSize(width: 100, height: 100).scaledSize(CGSize(width: 1000, height: 100))") {
                    let initial = CGSize(width: 100, height: 100)
                    let maxSize = CGSize(width: 1000, height: 100)
                    let subject = initial.scaledSize(maxSize)
                    expect(subject.width) == initial.width
                    expect(subject.height) == initial.height
                }
                it("CGSize(width: 100, height: 100).scaledSize(CGSize(width: 100, height: 100))") {
                    let initial = CGSize(width: 100, height: 100)
                    let maxSize = CGSize(width: 100, height: 100)
                    let subject = initial.scaledSize(maxSize)
                    expect(subject.width) == initial.width
                    expect(subject.height) == initial.height
                }
            }
            describe("should change the width") {
                it("CGSize(width: 1000, height: 500).scaledSize(CGSize(width: 100, height: 1000))") {
                    let initial = CGSize(width: 1000, height: 500)
                    let maxSize = CGSize(width: 100, height: 1000)
                    let subject = initial.scaledSize(maxSize)
                    expect(subject.width) == CGFloat(100)
                    expect(subject.height) == CGFloat(50)
                }
            }
            describe("should change the height") {
                it("CGSize(width: 500, height: 1000).scaledSize(CGSize(width: 1000, height: 100))") {
                    let initial = CGSize(width: 500, height: 1000)
                    let maxSize = CGSize(width: 1000, height: 100)
                    let subject = initial.scaledSize(maxSize)
                    expect(subject.width) == CGFloat(50)
                    expect(subject.height) == CGFloat(100)
                }
            }
            describe("should change the width and height") {
                it("CGSize(width: 1000, height: 1000).scaledSize(CGSize(width: 500, height: 100))") {
                    let initial = CGSize(width: 1000, height: 1000)
                    let maxSize = CGSize(width: 500, height: 100)
                    let subject = initial.scaledSize(maxSize)
                    expect(subject.width) == CGFloat(100)
                    expect(subject.height) == CGFloat(100)
                }
                it("CGSize(width: 1000, height: 1000).scaledSize(CGSize(width: 100, height: 500))") {
                    let initial = CGSize(width: 1000, height: 1000)
                    let maxSize = CGSize(width: 500, height: 100)
                    let subject = initial.scaledSize(maxSize)
                    expect(subject.width) == CGFloat(100)
                    expect(subject.height) == CGFloat(100)
                }
                it("CGSize(width: 1000, height: 1000).scaledSize(CGSize(width: 100, height: 100))") {
                    let initial = CGSize(width: 1000, height: 1000)
                    let maxSize = CGSize(width: 500, height: 100)
                    let subject = initial.scaledSize(maxSize)
                    expect(subject.width) == CGFloat(100)
                    expect(subject.height) == CGFloat(100)
                }
            }
        }
    }
}
