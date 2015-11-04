//
//  PostEditingService.swift
//  Ello
//
//  Created by Colin Gray on 2/12/14.
//  Copyright (c) 2015 Ello. All rights reserved.
//
// This service converts "raw" content (String, NSAttributedString, UIImage)
// into Regionables (TextRegion, ImageRegion) suitable for the API, and uploads
// or updates those.
//
// Retaining the index of each section is crucial, since the images are uploaded
// asynchronously, they could come back in any order.  In this context "entry"
// refers to the tuple of (index, Region) or (index, String/UIImage)

public class PostEditingService: NSObject {
    // this can return either a Post or Comment
    typealias CreatePostSuccessCompletion = (post: AnyObject) -> Void
    typealias UploadImagesSuccessCompletion = ([(Int, ImageRegion)]) -> Void

    public enum PostContentRegion {
        case Text(String)
        case ImageData(UIImage, NSData?, String?)
    }

    typealias ImageData = (UIImage, NSData?, String?)

    var editPost: Post?
    var editComment: Comment?
    var parentPost: Post?

    convenience init(parentPost post: Post) {
        self.init()
        parentPost = post
    }

    convenience init(editPost post: Post) {
        self.init()
        editPost = post
    }

    convenience init(editComment comment: Comment) {
        self.init()
        editComment = comment
    }

    // rawSections is String or UIImage objects
    func create(content rawContent: [PostContentRegion], authorId: String, success: CreatePostSuccessCompletion, failure: ElloFailureCompletion?) {
        var textEntries = [(Int, String)]()
        var imageDataEntries = [(Int, ImageData)]()

        // if necessary, the rawSource should be converted to API-ready content,
        // e.g. entitizing Strings and adding HTML markup to NSAttributedStrings
        for (index, section) in rawContent.enumerate() {
            switch section {
            case let .Text(text):
                textEntries.append((index, text))
            case let .ImageData(image, data, type):
                imageDataEntries.append((index, (image, data, type)))
            }
        }

        var indexedRegions: [(Int, Regionable)] = textEntries.map() { (index, text) -> (Int, Regionable) in
            return (index, TextRegion(content: text))
        }

        if imageDataEntries.count > 0 {
            uploadImages(imageDataEntries, success: { imageRegions in
                indexedRegions += imageRegions.map() { entry in
                    let (index, region) = entry
                    return (index, region as Regionable)
                }

                self.create(regions: self.sortedRegions(indexedRegions), authorId: authorId, success: success, failure: failure)
            }, failure: failure)
        }
        else {
            create(regions: sortedRegions(indexedRegions), authorId: authorId, success: success, failure: failure)
        }
    }

    func create(regions regions: [Regionable], authorId: String, success: CreatePostSuccessCompletion, failure: ElloFailureCompletion?) {
        let body = NSMutableArray(capacity: regions.count)
        for region in regions {
            body.addObject(region.toJSON())
        }
        let params = ["body": body]

        let endpoint: ElloAPI
        if let parentPost = parentPost {
            endpoint = ElloAPI.CreateComment(parentPostId: parentPost.id, body: params)
        }
        else if let editPost = editPost {
            endpoint = ElloAPI.UpdatePost(postId: editPost.id, body: params)
        }
        else if let editComment = editComment {
            endpoint = ElloAPI.UpdateComment(postId: editComment.postId, commentId: editComment.id, body: params)
        }
        else {
            endpoint = ElloAPI.CreatePost(body: params)
        }

        ElloProvider.elloRequest(endpoint,
            success: { data, responseConfig in
                let post: AnyObject = data

                switch endpoint {
                case .CreateComment:
                    let comment = data as! Comment
                    comment.content = self.replaceLocalImageRegions(comment.content, regions: regions)
                case .CreatePost, .UpdatePost:
                    let post = data as! Post
                    post.content = self.replaceLocalImageRegions(post.content ?? [], regions: regions)
                default:
                    break
                }

                success(post: post as AnyObject)
            },
            failure: failure
        )
    }

    func replaceLocalImageRegions(var content: [Regionable], regions: [Regionable]) -> [Regionable] {
        for (index, regionable) in content.enumerate() {
            if let _ = regionable as? ImageRegion,
                let replaceRegion = regions.safeValue(index) as? ImageRegion
            {
                content[index] = replaceRegion
            }
        }
        return content
    }

    // Each image is given its own "uploader", which will fetch new credentials
    // and thus a unique S3 storage bucket.
    //
    // Another way to upload the images would be to generate one AmazonCredentials
    // object, and pass that to the uploader.  The uploader would need to
    // generate unique image names in that case.
    func uploadImages(imageEntries: [(Int, ImageData)], success: UploadImagesSuccessCompletion, failure: ElloFailureCompletion?) {
        var uploaded = [(Int, ImageRegion)]()

        // if any upload fails, the entire post creationg fails
        var anyError: NSError?
        var anyStatusCode: Int?

        let operationQueue = NSOperationQueue.mainQueue()
        let doneOperation = NSBlockOperation(block: {
            if let error = anyError {
                failure?(error: error, statusCode: anyStatusCode)
            }
            else {
                success(uploaded)
            }
        })
        var prevUploadOperation: NSOperation?

        for dataEntry in imageEntries {
            let uploadOperation = AsyncOperation(block: { done in
                if anyError != nil {
                    done()
                    return
                }

                let (imageIndex, (image, data, contentType)) = dataEntry

                let filename: String
                switch contentType ?? "" {
                case "image/gif":
                    filename = "\(NSUUID().UUIDString).gif"
                case "image/png":
                    filename = "\(NSUUID().UUIDString).png"
                default:
                    filename = "\(NSUUID().UUIDString).jpg"
                }

                let failureHandler: ElloFailureCompletion = { error, statusCode in
                    anyError = error
                    anyStatusCode = statusCode
                    done()
                }

                let uploadService = S3UploadingService()
                if let data = data, contentType = contentType {
                    uploadService.upload(data, filename: filename, contentType: contentType,
                        success: { url in
                            let imageRegion = ImageRegion(alt: filename)
                            imageRegion.url = url

                            if let url = url {
                                let asset = Asset(url: url)
                                asset.optimized?.type = contentType
                                asset.optimized?.size = data.length
                                asset.optimized?.width = Int(image.size.width)
                                asset.optimized?.height = Int(image.size.height)

                                let attachment = Attachment(url: url)
                                attachment.width = Int(image.size.width)
                                attachment.height = Int(image.size.height)
                                attachment.image = image
                                asset.hdpi = attachment

                                ElloLinkedStore.sharedInstance.setObject(asset, forKey: asset.id, inCollection: MappingType.AssetsType.rawValue)
                                imageRegion.addLinkObject("assets", key: asset.id, collection: MappingType.AssetsType.rawValue)
                            }
                            
                            uploaded.append((imageIndex, imageRegion))
                            done()
                        },
                        failure: failureHandler)
                }
                else {
                    uploadService.upload(image, filename: filename,
                        success: { url in
                            let imageRegion = ImageRegion(alt: filename)
                            imageRegion.url = url

                            if let url = url {
                                let asset = Asset(image: image, url: url)
                                ElloLinkedStore.sharedInstance.setObject(asset, forKey: asset.id, inCollection: MappingType.AssetsType.rawValue)
                                imageRegion.addLinkObject("assets", key: asset.id, collection: MappingType.AssetsType.rawValue)
                            }

                            uploaded.append((imageIndex, imageRegion))
                            done()
                        },
                        failure: failureHandler)
                }
            })

            doneOperation.addDependency(uploadOperation)
            if let prevUploadOperation = prevUploadOperation {
                uploadOperation.addDependency(prevUploadOperation)
            }
            uploadOperation.queuePriority = .Low
            uploadOperation.qualityOfService = .Background
            operationQueue.addOperation(uploadOperation)
            prevUploadOperation = uploadOperation
        }
        operationQueue.addOperation(doneOperation)
    }

    // this happens just before create(regions:).  The original index of each
    // section has been stored in `entry.0`, and this is used to sort the
    // entries, and then the sorted regions are returned.
    private func sortedRegions(indexedRegions: [(Int, Regionable)]) -> [Regionable] {
        return indexedRegions.sort() { left, right in
            let (indexLeft, indexRight) = (left.0, right.0)
            return indexLeft < indexRight
        }.map() { (index: Int, region: Regionable) -> Regionable in
            return region
        }
    }

}
