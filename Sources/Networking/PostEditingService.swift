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
    typealias CreatePostSuccessCompletion = (post : AnyObject) -> ()
    typealias UploadImagesSuccessCompletion = ([(Int, ImageRegion)]) -> ()

    var parentPost: Post?

    convenience init(parentPost post: Post) {
        self.init()
        parentPost = post
    }

    // rawSections is String or UIImage objects
    func create(content rawContent: [AnyObject], authorId: String, success: CreatePostSuccessCompletion, failure: ElloFailureCompletion?) {
        var textEntries = [(Int, String)]()
        var imageEntries = [(Int, UIImage)]()

        // if necessary, the rawSource should be converted to API-ready content,
        // e.g. entitizing Strings and adding HTML markup to NSAttributedStrings
        for (index, section) in enumerate(rawContent) {
            if let text = section as? String {
                textEntries.append((index, text.entitiesEncoded()))
            }
            else if let image = section as? UIImage {
                imageEntries.append((index, image))
            }
            else if let attributed = section as? NSAttributedString {
                textEntries.append((index, attributed.string.entitiesEncoded()))
            }
        }

        var indexedRegions: [(Int, Regionable)] = textEntries.map() { (index, text) -> (Int, Regionable) in
            return (index, TextRegion(content: text))
        }

        if imageEntries.count > 0 {
            uploadImages(imageEntries, success: { imageRegions in
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

    func create(#regions: [Regionable], authorId: String, success: CreatePostSuccessCompletion, failure: ElloFailureCompletion?) {
        let body = NSMutableArray(capacity: regions.count)
        for region in regions {
            body.addObject(region.toJSON())
        }
        let params = ["body": body]

        var endpoint: ElloAPI
        if let parentPost = parentPost {
            endpoint = ElloAPI.CreateComment(parentPostId: parentPost.id, body: params)
        }
        else {
            endpoint = ElloAPI.CreatePost(body: params)
        }

        ElloProvider.elloRequest(endpoint,
            method: .POST,
            success: { data, responseConfig in
                var post: AnyObject = data

                switch endpoint {
                case .CreateComment:
                    let comment = data as! Comment
                    // this assumes that
                    var regionsCopy = regions
                    for (index, regionable) in enumerate(comment.content) {
                        if  let textRegion = regionable as? TextRegion,
                            let localTextRegion = regionsCopy[0] as? TextRegion
                        {
                            regionsCopy[0] = textRegion
                        }
                    }
                    let localComment = Comment(
                        id: comment.id,
                        createdAt: comment.createdAt,
                        authorId: comment.authorId,
                        postId: comment.postId,
                        content: regionsCopy
                    )
                    post = localComment
                    postNotification(UpdatePostCommentCountNotification, localComment)
                default:
                    break
                }

                success(post: post as AnyObject)
            },
            failure: failure
        )
    }

    // Each image is given its own "uploader", which will fetch new credentials
    // and thus a unique S3 storage bucket.
    //
    // Another way to upload the images would be to generate one AmazonCredentials
    // object, and pass that to the uploader.  The uploader would need to
    // generate unique image names in that case.
    func uploadImages(imageEntries : [(Int, UIImage)], success: UploadImagesSuccessCompletion, failure: ElloFailureCompletion?) {
        var uploaded = [(Int, ImageRegion)]()

        // if any upload fails, the entire post creationg fails
        var anyError : NSError?
        var anyStatusCode : Int?

        let allDone = Functional.after(imageEntries.count) {
            if let error = anyError {
                failure?(error: error, statusCode: anyStatusCode)
            }
            else {
                success(uploaded)
            }
        }

        for imageEntry in imageEntries {
            if let error = anyError {
                allDone()
                continue
            }

            let (imageIndex, image) = imageEntry
            let filename = "\(NSUUID().UUIDString).png"

            let uploadService = S3UploadingService()
            uploadService.upload(image, filename: filename,
                success: { url in
                    let imageRegion = ImageRegion(alt: filename)
                    imageRegion.url = url

                    if let url = url {
                        let attachment = Attachment(url: url)
                        attachment.width = Int(image.size.width)
                        attachment.height = Int(image.size.height)

                        let asset = Asset(id: NSUUID().UUIDString)
                        asset.optimized = attachment

                        ElloLinkedStore.sharedInstance.setObject(asset, forKey: asset.id, inCollection: MappingType.AssetsType.rawValue)
                        imageRegion.addLinkObject("assets", key: asset.id, collection: MappingType.AssetsType.rawValue)
                    }

                    uploaded.append((imageIndex, imageRegion))
                    allDone()
                },
                failure: { error, statusCode in
                    anyError = error
                    anyStatusCode = statusCode
                    allDone()
                })
        }
    }

    // this happens just before create(regions:).  The original index of each
    // section has been stored in `entry.0`, and this is used to sort the
    // entries, and then the sorted regions are returned.
    private func sortedRegions(indexedRegions : [(Int, Regionable)]) -> [Regionable] {
        return indexedRegions.sorted() { left, right in
            let (indexLeft, indexRight) = (left.0, right.0)
            return indexLeft < indexRight
        }.map() { (index : Int, region : Regionable) -> Regionable in
            return region
        }
    }

}
