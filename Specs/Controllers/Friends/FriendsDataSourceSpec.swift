//
//  FriendsDataSourceSpec.swift
//  Ello
//
//  Created by Sean Dougherty on 11/22/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Quick
import Nimble
import Moya


class FriendsDataSourceSpec: QuickSpec {
    override func spec() {
        let vc = FriendsViewController.instantiateFromStoryboard()
        vc.loadView()
        vc.viewDidLoad()

//        let keyWindow = UIWindow(frame: UIScreen.mainScreen().bounds)
//        keyWindow.makeKeyAndVisible()
//        keyWindow.rootViewController = vc
//        vc.loadView()
//        vc.viewDidLoad()
        
        var dataSource: FriendsDataSource!
//        let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: UICollectionViewFlowLayout())
        let webView = UIWebView(frame: CGRectMake(0, 0, 320, 640))
        ElloProvider.sharedProvider = MoyaProvider(endpointsClosure: ElloProvider.endpointsClosure, stubResponses: true)
        var loadedActivities:[Activity]?
        
        describe("initialization", {

            beforeEach({
                dataSource = FriendsDataSource(testWebView: webView)
                vc.dataSource = dataSource
                StreamService().loadFriendStream({ (activities) -> () in
                    loadedActivities = activities
                }, failure: nil)
//                let activity1 = Activity(kind: Activity.ActivityKinds.FriendPost, activityId: 123, createdAt: NSDate(), subject: nil, subjectType: Activity.ActivitySubjectType.Post)
//                let activity2 = activity1
//                let activity3 = activity2
//                let activities = [activity1, activity2, activity3]
                dataSource.addActivities(loadedActivities!, completion: {
                    vc.collectionView.dataSource = dataSource
                    vc.collectionView.reloadData()
                })
            })

            describe("-collectionView:numberOfItemsInSection:", {

                it("returns 78", {
                    
                    expect(dataSource.collectionView(vc.collectionView, numberOfItemsInSection: 0)).to(equal(78))
                })
            })

            describe("-collectionView:cellForItemAtIndexPath:", {

//                it("returns a StreamHeaderCell", {
//                    let cell = dataSource.collectionView(vc.collectionView, cellForItemAtIndexPath: NSIndexPath(forItem: 0, inSection: 0))
//                    expect{cell}.toEventually(beAnInstanceOf(StreamHeaderCell.self))
//                    
//                })
            })
        })
    }
}
