//
//  DeleteAccountConfirmationViewControllerSpec.swift
//  Ello
//
//  Created by Tony DiPasquale on 4/24/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble


class DeleteAccountConfirmationViewControllerSpec: QuickSpec {
    override func spec() {
        var subject = DeleteAccountConfirmationViewController()

        describe("initialization") {
            beforeEach {
                subject = DeleteAccountConfirmationViewController()
                subject.loadView()
                subject.viewDidLoad()
            }

            it("IBOutlets are not nil") {
                expect(subject.titleLabel).notTo(beNil())
                expect(subject.infoLabel).notTo(beNil())
                expect(subject.buttonView).notTo(beNil())
                expect(subject.cancelView).notTo(beNil())
                expect(subject.cancelLabel).notTo(beNil())
            }
        }
    }
}