//
//  FriendsDataSourceSpec.swift
//  Ello
//
//  Created by Sean Dougherty on 11/22/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Quick
import Nimble


class FriendsDataSourceSpec: QuickSpec {
    override func spec() {

        var dataSource: FriendsDataSource!
        describe("initialization", {

            beforeEach({
                dataSource = FriendsDataSource()
            })

            describe("-collectionView:numberOfItemsInSection:", {

                it("returns 5", {
                    let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: UICollectionViewFlowLayout())
                    expect(dataSource.collectionView(collectionView, numberOfItemsInSection: 0)).to(equal(5))
                })
            })

            describe("-collectionView:cellForItemAtIndexPath:", {

                it("returns a friends cell", {
                    let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: UICollectionViewFlowLayout())
                })
            })
        })
    }
}
