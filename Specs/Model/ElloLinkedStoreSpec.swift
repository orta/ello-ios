//
//  ElloLinkedStoreSpec.swift
//  Ello
//
//  Created by Sean on 2/6/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble

class ElloLinkedStoreSpec: QuickSpec {
    override func spec() {

        describe("-parseLinked:") {

            it("parses 'linked' and adds objects to Store") {
                expect(ElloLinkedStore.store).to(beEmpty())
                let linked = [
                    "superheroes":[
                        ["id":"batman" as AnyObject],
                        ["id":"superman" as AnyObject]
                    ],
                    "villians":[
                        ["id":"joker" as AnyObject],
                        ["id":"lex luther" as AnyObject]
                    ]
                ]
                ElloLinkedStore.parseLinked(linked)

                expect(ElloLinkedStore.store["superheroes"]?["batman"]).toNot(beNil())
                expect(ElloLinkedStore.store["villians"]?["lex luther"]).toNot(beNil())
            }
        }
    }
}
