//
//  AvatarButtonSpec.swift
//  Ello
//
//  Created by Colin Gray on 10/30/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

@testable import Ello
import Quick
import Nimble


class AvatarButtonSpec: QuickSpec {
    override func spec() {
        describe("AvatarButton") {
            context("When size is 30x30") {
                it("should have correct starIcon sizes") {
                    let subject = AvatarButton()
                    subject.frame.size = CGSize(width: 30, height: 30)
                    subject.layoutIfNeeded()
                    expect(subject.starIcon.frame.size) == CGSize(width: 7.5, height: 7.5)
                }
            }
            context("When size is 60x60") {
                it("should have correct starIcon sizes") {
                    let subject = AvatarButton()
                    subject.frame.size = CGSize(width: 60, height: 60)
                    subject.layoutIfNeeded()
                    expect(subject.starIcon.frame.size) == CGSize(width: 15, height: 15)
                }
            }
        }
    }
}
