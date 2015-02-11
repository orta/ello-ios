//
//  ElloLinkedStoreSpec.swift
//  Ello
//
//  Created by Sean on 2/6/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Quick
import Nimble

class ElloLinkedStoreSpec: QuickSpec {
    override func spec() {

        describe("-parseLinked:") {

            it("parses 'linked' and adds objects to Store") {
                expect(Store.store).to(beEmpty())
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
                Store.parseLinked(linked)

                expect(Store.store["superheroes"]?["batman"]).toNot(beNil())
                expect(Store.store["villians"]?["lex luther"]).toNot(beNil())
            }
            
        }
    }
}
