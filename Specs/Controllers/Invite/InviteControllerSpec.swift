//
//  InviteControllerSpec.swift
//  Ello
//
//  Created by Tony DiPasquale on 3/12/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Quick
import Nimble

class InviteControllerSpec: QuickSpec {
    override func spec() {
        beforeSuite {
            ElloProvider.sharedProvider = ElloProvider.StubbingProvider()
        }

        afterSuite {
            ElloProvider.sharedProvider = ElloProvider.DefaultProvider()
        }

        describe("sendInvite") {
            it("should call didUpdate when finished") {
                let person = LocalPerson(name: "test", emails: ["person@somewhere.com"], id: 1)
                var didUpdate = false
                let controller = InviteController(person: person) {
                    didUpdate = true
                }
                controller.sendInvite()

                expect(didUpdate).toEventually(beTrue())
            }
        }
    }
}
