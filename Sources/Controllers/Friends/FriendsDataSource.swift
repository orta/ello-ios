//
//  FriendsDataSource.swift
//  Ello
//
//  Created by Sean Dougherty on 11/22/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit
import WebKit

class FriendsDataSource: NSObject, UICollectionViewDataSource {

    typealias StreamContentReady = () -> ()

    enum CellIdentifier: String {
        case Header = "StreamHeaderCell"
        case Footer = "StreamFooterCell"
        case Image = "StreamImageCell"
        case Text = "StreamTextCell"
        case Unknown = "StreamUnknownCell"
    }

    var indexFile:String?
    var contentReadyClosure:StreamContentReady?
    var streamCellItems:[StreamCellItem]?
    let testWebView:UIWebView
    let sizeCalculator:StreamTextCellSizeCalculator

    init(testWebView: UIWebView) {
        self.testWebView = testWebView
        self.sizeCalculator = StreamTextCellSizeCalculator(webView: testWebView)
        super.init()
    }

    func addActivities(activities:[Activity], completion:StreamContentReady) {
        self.contentReadyClosure = completion
        self.streamCellItems = self.createStreamCellItems(activities)
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
        switch streamCellItem.type {
        case .Header:
            return headerCell(streamCellItem, collectionView: collectionView, indexPath: indexPath)
        case .BodyElement:
            return cellForBodyElement(streamCellItem, collectionView: collectionView, indexPath: indexPath)
        case .Footer:
            return footerCell(streamCellItem, collectionView: collectionView, indexPath: indexPath)
        }
    }

    private func headerCell(streamCellItem:StreamCellItem, collectionView: UICollectionView, indexPath: NSIndexPath) -> StreamHeaderCell {
        let post:Post = streamCellItem.activity.subject as Post
        let streamCell = collectionView.dequeueReusableCellWithReuseIdentifier(CellIdentifier.Header.rawValue, forIndexPath: indexPath) as StreamHeaderCell
        if let avatarURL = post.author?.avatarURL? {
            streamCell.setAvatarURL(avatarURL)
        }
        streamCell.timestampLabel.text = NSDate().distanceOfTimeInWords(post.createdAt)
        streamCell.usernameLabel.text = "@" + (post.author?.username ?? "meow")
        return streamCell
    }

    private func cellForBodyElement(streamCellItem:StreamCellItem, collectionView: UICollectionView, indexPath: NSIndexPath) -> UICollectionViewCell {

        switch streamCellItem.data!.type {
        case Post.BodyElementTypes.Image:
            return imageCell(streamCellItem, collectionView: collectionView, indexPath: indexPath)
        case Post.BodyElementTypes.Text:
            return textCell(streamCellItem, collectionView: collectionView, indexPath: indexPath)
        case Post.BodyElementTypes.Unknown:
            return collectionView.dequeueReusableCellWithReuseIdentifier(CellIdentifier.Unknown.rawValue, forIndexPath: indexPath) as UICollectionViewCell
        }
    }

    private func footerCell(streamCellItem:StreamCellItem, collectionView: UICollectionView, indexPath: NSIndexPath) -> StreamFooterCell {
        let post:Post = streamCellItem.activity.subject as Post
        let footerCell = collectionView.dequeueReusableCellWithReuseIdentifier(CellIdentifier.Footer.rawValue, forIndexPath: indexPath) as StreamFooterCell
        footerCell.views = post.viewedCount.localizedStringFromNumber()
        footerCell.comments = post.commentCount.localizedStringFromNumber()
        return footerCell
    }

    private func imageCell(streamCellItem:StreamCellItem, collectionView: UICollectionView, indexPath: NSIndexPath) -> StreamImageCell {
        let imageCell = collectionView.dequeueReusableCellWithReuseIdentifier(CellIdentifier.Image.rawValue, forIndexPath: indexPath) as StreamImageCell
        if let photoData = streamCellItem.data as Post.ImageBodyElement? {
            if let photoURL = photoData.url? {
                imageCell.setImageURL(photoURL)
            }
        }
        return imageCell
    }

    private func textCell(streamCellItem:StreamCellItem, collectionView: UICollectionView, indexPath: NSIndexPath) -> StreamTextCell {
        let textCell = collectionView.dequeueReusableCellWithReuseIdentifier(CellIdentifier.Text.rawValue, forIndexPath: indexPath) as StreamTextCell
        textCell.contentView.alpha = 0.0
        if let textData = streamCellItem.data as Post.TextBodyElement? {
            textCell.webView.loadHTMLString(StreamTextCellHTML.postHTML(textData.content), baseURL: NSURL(string: "/"))
        }
        return textCell
    }

    private func createStreamCellItems(activities:[Activity]) -> [StreamCellItem]? {
        let parser = StreamCellItemParser()
        var cellItems = parser.streamCellItems(activities)

        let textElements = cellItems.filter {
            return $0.data as? Post.TextBodyElement != nil
        }

        self.sizeCalculator.processCells(textElements, {
            if let ready = self.contentReadyClosure {
                ready()
            }
        })

        return cellItems
    }
}