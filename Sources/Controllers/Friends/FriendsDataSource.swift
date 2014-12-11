//
//  FriendsDataSource.swift
//  Ello
//
//  Created by Sean Dougherty on 11/22/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit

class FriendsDataSource: NSObject, UICollectionViewDataSource {

    typealias StreamCellItem = (activity:Activity, type:CellType, data:Post.BodyElement?, cellHeight:CGFloat)

    var streamCellItems:[StreamCellItem]?
    weak var viewController: UIViewController?

    var activities:[Activity]? {
        didSet {
            self.streamCellItems = self.createStreamCellItems()
        }
    }

    enum CellType {
        case Header
        case Footer
        case BodyElement
    }

    func updateHeightForIndexPath(indexPath:NSIndexPath?, height:CGFloat) {
        if let indexPath = indexPath {
            streamCellItems?[indexPath.item].cellHeight = height
        }
    }

    func heightForIndexPath(indexPath:NSIndexPath) -> CGFloat {
        return streamCellItems?[indexPath.item].cellHeight ?? 0.0
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return streamCellItems?.count ?? 0
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        var cell:UICollectionViewCell
        if let streamCellItem = streamCellItems?[indexPath.item] {

            let activity = streamCellItem.activity

            switch activity.subjectType {
            case .Post:
                return postCellForActivity(streamCellItem, collectionView: collectionView, indexPath: indexPath)
            case .User:
                return postCellForActivity(streamCellItem, collectionView: collectionView, indexPath: indexPath)
            case .Unknown:
                return postCellForActivity(streamCellItem, collectionView: collectionView, indexPath: indexPath)
            }

        }

        return UICollectionViewCell()
    }

    private func postCellForActivity(streamCellItem:StreamCellItem, collectionView: UICollectionView, indexPath: NSIndexPath) -> UICollectionViewCell {
        let post:Post = streamCellItem.activity.subject as Post

        var cell = UICollectionViewCell()
        switch streamCellItem.type {
        case .Header:
            if let streamCell = collectionView.dequeueReusableCellWithReuseIdentifier("StreamCell", forIndexPath: indexPath) as? StreamCell {
                if let avatarURL = post.author?.avatarURL? {
                    streamCell.setAvatarURL(avatarURL)
                }
                streamCell.timestampLabel.text = NSDate().distanceOfTimeInWords(post.createdAt)
                streamCell.usernameLabel.text = "@" + (post.author?.username ?? "meow")
                cell = streamCell
            }
        case .BodyElement:
            cell = cellForBodyElement(streamCellItem, collectionView: collectionView, indexPath: indexPath)
        case .Footer:
            cell = collectionView.dequeueReusableCellWithReuseIdentifier("StreamFooterCell", forIndexPath: indexPath) as UICollectionViewCell

            if let cell = cell as? StreamFooterCell {
                cell.views = post.viewedCount.localizedStringFromNumber()
                cell.comments = post.commentCount.localizedStringFromNumber()
            }

        }

        return cell
    }

    private func cellForBodyElement(streamCellItem:StreamCellItem, collectionView: UICollectionView, indexPath: NSIndexPath) -> UICollectionViewCell {

        var cell = UICollectionViewCell()
        switch streamCellItem.data!.type {
        case Post.BodyElementTypes.Image:
            if let imageCell = collectionView.dequeueReusableCellWithReuseIdentifier("StreamImageCell", forIndexPath: indexPath) as? StreamImageCell {
                if let photoData = streamCellItem.data as Post.ImageBodyElement? {
                    if let photoURL = photoData.url? {
                        imageCell.setImageURL(photoURL)
                        imageCell.viewController = self.viewController
                    }
                }

                cell = imageCell
            }
        case Post.BodyElementTypes.Text:
            cell = collectionView.dequeueReusableCellWithReuseIdentifier("StreamTextCell", forIndexPath: indexPath) as UICollectionViewCell
        case Post.BodyElementTypes.Unknown:
            cell = collectionView.dequeueReusableCellWithReuseIdentifier("StreamUnknownCell", forIndexPath: indexPath) as UICollectionViewCell
        }

        return cell
    }

//    private func numberOfCells() -> Int? {
//        return activities?.reduce(0, combine: { (elementCount:Int, activity:Activity) -> Int in
//            if activity.subjectType == .Post {
//                if let post = activity.subject as? Post {
//                    return post.body.count + elementCount + 1
//                }
//            }
//            return elementCount
//        })
//    }

    private func createStreamCellItems() -> [StreamCellItem]? {
        if activities != nil {
            var cellArray:[StreamCellItem] = []
            for activity in activities! {
                let headerTuple:StreamCellItem = (activity, CellType.Header, nil, 80.0)
                cellArray.append(headerTuple)

                if let post = activity.subject as? Post {
                    for element in post.body {
                        var height:CGFloat
                        switch element.type {
                        case Post.BodyElementTypes.Image:
                            height = UIScreen.screenWidth() / (4/3)
                        case Post.BodyElementTypes.Text:
                            height = 120.0
                        case Post.BodyElementTypes.Unknown:
                            height = 120.0
                        }

                        let bodyTuple:StreamCellItem = (activity, CellType.BodyElement, element, height)
                        cellArray.append(bodyTuple)
                    }
                }

                let footerTuple:StreamCellItem = (activity, CellType.Footer, nil, 54.0)
                cellArray.append(footerTuple)
            }
            return cellArray
        }
        else {
            return nil
        }
    }
}
