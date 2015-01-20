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

    init(testWebView: UIWebView) {
        self.testWebView = testWebView
        self.sizeCalculator = StreamTextCellSizeCalculator(webView: testWebView)
        super.init()
    }
    
    func postForIndexPath(indexPath:NSIndexPath) -> Post? {
        if indexPath.item >= streamCellItems.count {
            return nil
        }
        return streamCellItems[indexPath.item].activity?.subject as? Post
    }
    
    func cellItemsForPost(post:Post) -> [StreamCellItem]? {
        return streamCellItems.filter({ (item) -> Bool in
            if let cellPost = item.activity?.subject as? Post {
                return post.postId == cellPost.postId
            }
            else {
                return false
            }
        })
    }

    func addActivities(activities:[Activity], completion:StreamContentReady) {
        self.contentReadyClosure = completion
        self.streamCellItems = self.createStreamCellItems(activities)
    }
    
    func addComments(comments:[Comment], completion:StreamContentReady) {
        self.contentReadyClosure = completion
        createAndAddCommentStreamCellItems(comments)
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
            
            if let activity = streamCellItem.activity {
                switch activity.subjectType {
                case .Post:
                    return postCellForActivity(streamCellItem, collectionView: collectionView, indexPath: indexPath)
                case .User:
                    return postCellForActivity(streamCellItem, collectionView: collectionView, indexPath: indexPath)
                case .Unknown:
                    return postCellForActivity(streamCellItem, collectionView: collectionView, indexPath: indexPath)
                }
            }
            else if let comment = streamCellItem.comment {
                return cellForComment(streamCellItem, collectionView: collectionView, indexPath: indexPath)
            }
        }
       
        return UICollectionViewCell()
    }

    private func cellForComment(streamCellItem:StreamCellItem, collectionView: UICollectionView, indexPath: NSIndexPath) -> UICollectionViewCell {
        switch streamCellItem.type {
        case .CommentHeader:
            return commentHeaderCell(streamCellItem, collectionView: collectionView, indexPath: indexPath)
        case .CommentBodyElement:
            return cellForBodyElement(streamCellItem, collectionView: collectionView, indexPath: indexPath)
        case .Footer:
            return footerCell(streamCellItem, collectionView: collectionView, indexPath: indexPath)
        default:
            return UICollectionViewCell()
        }
    }
    
    private func postCellForActivity(streamCellItem:StreamCellItem, collectionView: UICollectionView, indexPath: NSIndexPath) -> UICollectionViewCell {
        switch streamCellItem.type {
        case .Header:
            return headerCell(streamCellItem, collectionView: collectionView, indexPath: indexPath)
        case .BodyElement:
            return cellForBodyElement(streamCellItem, collectionView: collectionView, indexPath: indexPath)
        case .Footer:
            return footerCell(streamCellItem, collectionView: collectionView, indexPath: indexPath)
        default:
            return UICollectionViewCell()
        }
    }

    private func commentHeaderCell(streamCellItem:StreamCellItem, collectionView: UICollectionView, indexPath: NSIndexPath) -> StreamCommentHeaderCell {
 
        let streamCell = collectionView.dequeueReusableCellWithReuseIdentifier(CellIdentifier.CommentHeader.rawValue, forIndexPath: indexPath) as StreamCommentHeaderCell

        var author:User? = streamCellItem.comment?.author
        
        if let avatarURL = author?.avatarURL? {
            streamCell.setAvatarURL(avatarURL)
        }
        
        if let comment = streamCellItem.comment {
            streamCell.timestampLabel.text = NSDate().distanceOfTimeInWords(comment.createdAt)
        }
        
        streamCell.usernameLabel.text = "@" + (author?.username ?? "meow")
        return streamCell
    }
    
    private func headerCell(streamCellItem:StreamCellItem, collectionView: UICollectionView, indexPath: NSIndexPath) -> StreamHeaderCell {
        
        var author:User?
        if let post:Post = streamCellItem.activity?.subject as? Post {
            author = post.author?
        }
        else if let user:User = streamCellItem.activity?.subject as? User {
            author = user
        }

        let streamCell = collectionView.dequeueReusableCellWithReuseIdentifier(CellIdentifier.Header.rawValue, forIndexPath: indexPath) as StreamHeaderCell
        if let avatarURL = author?.avatarURL? {
            streamCell.setAvatarURL(avatarURL)
        }
        
        if let activity = streamCellItem.activity {
            streamCell.timestampLabel.text = NSDate().distanceOfTimeInWords(activity.createdAt)
        }
        
        streamCell.usernameLabel.text = "@" + (author?.username ?? "meow")
        return streamCell
    }

    private func cellForBodyElement(streamCellItem:StreamCellItem, collectionView: UICollectionView, indexPath: NSIndexPath) -> UICollectionViewCell {

        switch streamCellItem.data!.kind {
        case Block.Kind.Image:
            return imageCell(streamCellItem, collectionView: collectionView, indexPath: indexPath)
        case Block.Kind.Text:
            return textCell(streamCellItem, collectionView: collectionView, indexPath: indexPath)
        case Block.Kind.Unknown:
            return collectionView.dequeueReusableCellWithReuseIdentifier(CellIdentifier.Unknown.rawValue, forIndexPath: indexPath) as UICollectionViewCell
        }
    }

    private func footerCell(streamCellItem:StreamCellItem, collectionView: UICollectionView, indexPath: NSIndexPath) -> StreamFooterCell {
        let post:Post = streamCellItem.activity?.subject as Post
        let footerCell = collectionView.dequeueReusableCellWithReuseIdentifier(CellIdentifier.Footer.rawValue, forIndexPath: indexPath) as StreamFooterCell
        footerCell.views = post.viewsCount?.localizedStringFromNumber()
        footerCell.comments = post.commentsCount?.localizedStringFromNumber()
        return footerCell
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
        let textCell = collectionView.dequeueReusableCellWithReuseIdentifier(CellIdentifier.Text.rawValue, forIndexPath: indexPath) as StreamTextCell
        textCell.contentView.alpha = 0.0
        if let textData = streamCellItem.data as TextBlock? {
            textCell.webView.loadHTMLString(StreamTextCellHTML.postHTML(textData.content), baseURL: NSURL(string: "/"))
        }
        return textCell
    }

    private func createStreamCellItems(activities:[Activity]) -> [StreamCellItem] {
        let parser = StreamCellItemParser()
        var cellItems = parser.streamCellItems(activities)

        let textElements = cellItems.filter {
            return $0.data as? TextBlock != nil
        }

        self.sizeCalculator.processCells(textElements, {
            if let ready = self.contentReadyClosure {
                ready()
            }
        })

        return cellItems
    }
    
    private func createAndAddCommentStreamCellItems(comments:[Comment]) -> [StreamCellItem] {
        let parser = StreamCellItemParser()
        var cellItems = parser.streamCellItems(comments)
        
        let textElements = cellItems.filter {
            return $0.data as? TextBlock != nil
        }
        
        self.sizeCalculator.processCells(textElements, {
            self.streamCellItems += cellItems
            if let ready = self.contentReadyClosure {
                ready()
            }
        })
        
        return self.streamCellItems
    }
}