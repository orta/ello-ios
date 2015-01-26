//
//  StreamDataSource.swift
//  Ello
//
//  Created by Sean Dougherty on 11/22/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit
import WebKit

class StreamDataSource: NSObject, UICollectionViewDataSource {

    typealias StreamContentReady = (indexPaths:[NSIndexPath]) -> ()

    enum CellIdentifier: String {
        case CommentHeader = "StreamCommentHeaderCell"
        case Header = "StreamHeaderCell"
        case Footer = "StreamFooterCell"
        case Image = "StreamImageCell"
        case Text = "StreamTextCell"
        case Comment = "StreamCommentCell"
        case Unknown = "StreamUnknownCell"
    }

    var indexFile:String?
    var contentReadyClosure:StreamContentReady?
    var streamCellItems:[StreamCellItem] = []
    let testWebView:UIWebView
    let sizeCalculator:StreamTextCellSizeCalculator
    var postbarDelegate:PostbarDelegate?

    init(testWebView: UIWebView) {
        self.testWebView = testWebView
        self.sizeCalculator = StreamTextCellSizeCalculator(webView: testWebView)
        super.init()
    }
    
    func postForIndexPath(indexPath:NSIndexPath) -> Post? {
        if indexPath.item >= streamCellItems.count {
            return nil
        }
        return streamCellItems[indexPath.item].streamable as? Post
    }
    
    func cellItemsForPost(post:Post) -> [StreamCellItem]? {
        return streamCellItems.filter({ (item) -> Bool in
            if let cellPost = item.streamable as? Post {
                return post.postId == cellPost.postId
            }
            else {
                return false
            }
        })
    }

    func commentIndexPathsForPost(post: Post) -> [NSIndexPath] {
        var indexPaths:[NSIndexPath] = []

        for (index,value) in enumerate(streamCellItems) {

            if let comment = value.streamable as? Comment {
                if comment.parentPost?.postId == post.postId {
                    indexPaths.append(NSIndexPath(forItem: index, inSection: 0))
                }
            }
        }
        return indexPaths
    }

    func addStreamables(streamables:[Streamable], completion:StreamContentReady, startingIndexPath:NSIndexPath?) {
        self.contentReadyClosure = completion
        self.streamCellItems = self.createStreamCellItems(streamables, startingIndexPath: startingIndexPath)
    }

    func updateHeightForIndexPath(indexPath:NSIndexPath?, height:CGFloat) {
        if let indexPath = indexPath {
            streamCellItems[indexPath.item].cellHeight = height
        }
    }

    func heightForIndexPath(indexPath:NSIndexPath) -> CGFloat {
        return streamCellItems[indexPath.item].cellHeight ?? 0.0
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return streamCellItems.count ?? 0
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if indexPath.item < countElements(streamCellItems) {
            let streamCellItem = streamCellItems[indexPath.item]

            switch streamCellItem.type {
            case .Header, .CommentHeader:
                return headerCell(streamCellItem, collectionView: collectionView, indexPath: indexPath)
            case .BodyElement, .CommentBodyElement:
                return bodyCell(streamCellItem, collectionView: collectionView, indexPath: indexPath)
            case .Footer:
                return footerCell(streamCellItem, collectionView: collectionView, indexPath: indexPath)
            default:
                return UICollectionViewCell()
            }
        }
       
        return UICollectionViewCell()
    }
    
    private func headerCell(streamCellItem:StreamCellItem, collectionView: UICollectionView, indexPath: NSIndexPath) -> UICollectionViewCell {

        var headerCell:StreamHeaderCell = StreamHeaderCell()
        switch streamCellItem.streamable.kind {
        case .Comment:
            headerCell = collectionView.dequeueReusableCellWithReuseIdentifier(CellIdentifier.CommentHeader.rawValue, forIndexPath: indexPath) as StreamCommentHeaderCell
        default:
            headerCell = collectionView.dequeueReusableCellWithReuseIdentifier(CellIdentifier.Header.rawValue, forIndexPath: indexPath) as StreamHeaderCell
        }
        
        
        if let avatarURL = streamCellItem.streamable.author?.avatarURL? {
            headerCell.setAvatarURL(avatarURL)
        }

        headerCell.timestampLabel.text = NSDate().distanceOfTimeInWords(streamCellItem.streamable.createdAt)

        headerCell.usernameLabel.text = "@" + (streamCellItem.streamable.author?.username ?? "meow")
        return headerCell
    }
    
    private func bodyCell(streamCellItem:StreamCellItem, collectionView: UICollectionView, indexPath: NSIndexPath) -> UICollectionViewCell {

        switch streamCellItem.data!.kind {
        case Block.Kind.Image:
            return imageCell(streamCellItem, collectionView: collectionView, indexPath: indexPath)
        case Block.Kind.Text:
            return textCell(streamCellItem, collectionView: collectionView, indexPath: indexPath)
        case Block.Kind.Unknown:
            return collectionView.dequeueReusableCellWithReuseIdentifier(CellIdentifier.Unknown.rawValue, forIndexPath: indexPath) as UICollectionViewCell
        }
    }

    private func imageCell(streamCellItem:StreamCellItem, collectionView: UICollectionView, indexPath: NSIndexPath) -> StreamImageCell {
        let imageCell = collectionView.dequeueReusableCellWithReuseIdentifier(CellIdentifier.Image.rawValue, forIndexPath: indexPath) as StreamImageCell
        if let photoData = streamCellItem.data as ImageBlock? {
            if let photoURL = photoData.url? {
                imageCell.setImageURL(photoURL)
            }
        }
        return imageCell
    }

    private func textCell(streamCellItem:StreamCellItem, collectionView: UICollectionView, indexPath: NSIndexPath) -> StreamTextCell {
        var textCell:StreamTextCell = collectionView.dequeueReusableCellWithReuseIdentifier(CellIdentifier.Text.rawValue, forIndexPath: indexPath) as StreamTextCell

        textCell.contentView.alpha = 0.0
        if let textData = streamCellItem.data as TextBlock? {
            textCell.webView.loadHTMLString(StreamTextCellHTML.postHTML(textData.content), baseURL: NSURL(string: "/"))
        }

        if let comment = streamCellItem.streamable as? Comment {
            textCell.leadingConstraint.constant = 58.0
        }
        else {
            textCell.leadingConstraint.constant = 0.0
        }
        return textCell
    }
    
    private func footerCell(streamCellItem:StreamCellItem, collectionView: UICollectionView, indexPath: NSIndexPath) -> StreamFooterCell {
        if let post = streamCellItem.streamable as? Post {
            let footerCell = collectionView.dequeueReusableCellWithReuseIdentifier(CellIdentifier.Footer.rawValue, forIndexPath: indexPath) as StreamFooterCell
            footerCell.delegate = self.postbarDelegate
            footerCell.views = post.viewsCount?.localizedStringFromNumber()
            footerCell.comments = post.commentsCount?.localizedStringFromNumber()
            footerCell.reposts = post.repostsCount?.localizedStringFromNumber()
            
            return footerCell
        }
        
        return StreamFooterCell()
    }

    private func createStreamCellItems(streamables:[Streamable], startingIndexPath:NSIndexPath?) -> [StreamCellItem] {
        var cellItems = StreamCellItemParser().streamCellItems(streamables)

        let textElements = cellItems.filter {
            return $0.data as? TextBlock != nil
        }

        self.sizeCalculator.processCells(textElements, {
            var indexPaths:[NSIndexPath] = []

            var indexPath:NSIndexPath = startingIndexPath ?? NSIndexPath(forItem: countElements(self.streamCellItems) - 1, inSection: 0)

            for (index, cellItem) in enumerate(cellItems) {
                var index = indexPath.item + index + 1
                indexPaths.append(NSIndexPath(forItem: index, inSection: 0))
                self.streamCellItems.insert(cellItem, atIndex: index)
            }

            self.contentReadyClosure?(indexPaths: indexPaths)
        })

        return self.streamCellItems
    }
}