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

    typealias StreamCellItem = (activity:Activity, type:CellType, data:Post.BodyElement?, cellHeight:CGFloat)

    var streamCellItems:[StreamCellItem]?
    var testWebView:UIWebView?

    init(controller: UIViewController) {
        viewController = controller
        testWebView = UIWebView(frame: controller.view.frame)
        super.init()
    }

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
        var cell = UICollectionViewCell()
        switch streamCellItem.type {
        case .Header:
            cell = headerCell(streamCellItem, collectionView: collectionView, indexPath: indexPath)
        case .BodyElement:
            cell = cellForBodyElement(streamCellItem, collectionView: collectionView, indexPath: indexPath)
        case .Footer:
            cell = footerCell(streamCellItem, collectionView: collectionView, indexPath: indexPath)
        }
        return cell
    }

    private func headerCell(streamCellItem:StreamCellItem, collectionView: UICollectionView, indexPath: NSIndexPath) -> StreamCell {
        let post:Post = streamCellItem.activity.subject as Post
        let streamCell = collectionView.dequeueReusableCellWithReuseIdentifier("StreamCell", forIndexPath: indexPath) as StreamCell
        if let avatarURL = post.author?.avatarURL? {
            streamCell.setAvatarURL(avatarURL)
        }
        streamCell.timestampLabel.text = NSDate().distanceOfTimeInWords(post.createdAt)
        streamCell.usernameLabel.text = "@" + (post.author?.username ?? "meow")
        return streamCell
    }

    private func cellForBodyElement(streamCellItem:StreamCellItem, collectionView: UICollectionView, indexPath: NSIndexPath) -> UICollectionViewCell {

        var cell = UICollectionViewCell()
        switch streamCellItem.data!.type {
        case Post.BodyElementTypes.Image:
            cell = imageCell(streamCellItem, collectionView: collectionView, indexPath: indexPath)
        case Post.BodyElementTypes.Text:
            cell = textCell(streamCellItem, collectionView: collectionView, indexPath: indexPath)
        case Post.BodyElementTypes.Unknown:
            cell = collectionView.dequeueReusableCellWithReuseIdentifier("StreamUnknownCell", forIndexPath: indexPath) as UICollectionViewCell
        }

        return cell
    }

    private func footerCell(streamCellItem:StreamCellItem, collectionView: UICollectionView, indexPath: NSIndexPath) -> StreamFooterCell {
        let post:Post = streamCellItem.activity.subject as Post
        let footerCell = collectionView.dequeueReusableCellWithReuseIdentifier("StreamFooterCell", forIndexPath: indexPath) as StreamFooterCell
        footerCell.views = post.viewedCount.localizedStringFromNumber()
        footerCell.comments = post.commentCount.localizedStringFromNumber()
        return footerCell
    }

    private func imageCell(streamCellItem:StreamCellItem, collectionView: UICollectionView, indexPath: NSIndexPath) -> StreamImageCell {
        let imageCell = collectionView.dequeueReusableCellWithReuseIdentifier("StreamImageCell", forIndexPath: indexPath) as StreamImageCell
        if let photoData = streamCellItem.data as Post.ImageBodyElement? {
            if let photoURL = photoData.url? {
                imageCell.setImageURL(photoURL)
                imageCell.viewController = self.viewController
            }
        }
        return imageCell
    }

    private func textCell(streamCellItem:StreamCellItem, collectionView: UICollectionView, indexPath: NSIndexPath) -> StreamTextCell {
        let textCell = collectionView.dequeueReusableCellWithReuseIdentifier("StreamTextCell", forIndexPath: indexPath) as StreamTextCell
        textCell.contentView.alpha = 0.0
        if let textData = streamCellItem.data as Post.TextBodyElement? {
            println("textCell")
            let indexHTML = NSBundle.mainBundle().pathForResource("index", ofType: "html", inDirectory: "www")!
            let indexURL = NSURL(string:indexHTML)!
            var req = NSURLRequest(URL:indexURL)

            var error:NSError?
            let indexAsText = NSString(contentsOfFile: indexHTML, encoding: NSUTF8StringEncoding, error: &error)
            if error == nil && indexAsText != nil {
                let postHTML = indexAsText!.stringByReplacingOccurrencesOfString("{{post-content}}", withString: textData.content)
                textCell.webView.loadHTMLString(postHTML, baseURL: NSURL(string: "/"))
            }
        }
        return textCell
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
                             height = estimatedTextCellHeight(element)
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

    private func estimatedTextCellHeight(element:Post.BodyElement) -> CGFloat {

        if let textData = element as? Post.TextBodyElement {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 18.0
            let attributes = [NSFontAttributeName : UIFont.typewriterFont(12.0),
                NSParagraphStyleAttributeName : paragraphStyle]

            let constrainedSize = CGSizeMake(self.viewController!.view.frame.size.width, CGFloat.max)
            let string = NSString(string: textData.content.stripHTML())
            let rect = string.boundingRectWithSize(constrainedSize,
                options: NSStringDrawingOptions.UsesLineFragmentOrigin,
                attributes: attributes,
                context: nil)

            return rect.size.height
        }
        else {
            return 120.0
        }
    }
}
