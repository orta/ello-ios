//
//  AddFriendsDataSourceSpec.swift
//  Ello
//
//  Created by Sean on 2/26/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Quick
import Nimble


class AddFriendsDataSourceSpec: QuickSpec {
    override func spec() {

        var subject = AddFriendsDataSource()

        beforeSuite {
            ElloProvider.sharedProvider = ElloProvider.StubbingProvider()
        }

        afterSuite {
            ElloProvider.sharedProvider = ElloProvider.DefaultProvider()
        }

        describe("initialization") {

            beforeEach {
                subject = AddFriendsDataSource()
            }

            it("is a UITableViewDataSource") {
                let dataSource = subject as UITableViewDataSource
                expect(dataSource).toNot(beNil())
            }
        }
    }
}
