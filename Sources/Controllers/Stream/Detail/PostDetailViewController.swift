//
//  PostDetailViewController.swift
//  Ello
//
//  Created by Colin Gray on 2/5/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public class PostDetailViewController: StreamableViewController {

    var post: Post?
    var postParam: String!
    var scrollToComment: Comment?

    var navigationBar: ElloNavigationBar!
    var localToken: String!
    var deeplinkPath: String?

    required public init(postParam: String) {
        self.postParam = postParam
        super.init(nibName: nil, bundle: nil)
        self.localToken = streamViewController.resetInitialPageLoadingToken()
        ElloHUD.showLoadingHudInView(streamViewController.view)
        streamViewController.initialLoadClosure = reloadEntirePostDetail
        streamViewController.loadInitialPage()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        streamViewController.streamKind = .PostDetail(postParam: postParam)
        view.backgroundColor = .whiteColor()
    }

    // used to provide StreamableViewController access to the container it then
    // loads the StreamViewController's content into
    override func viewForStream() -> UIView {
        return view
    }

    private func updateInsets() {
        updateInsets(navBar: navigationBar, streamController: streamViewController)
    }

    override public func showNavBars(scrollToBottom : Bool) {
        super.showNavBars(scrollToBottom)
        positionNavBar(navigationBar, visible: true)
        updateInsets()

        if scrollToBottom {
            self.scrollToBottom(streamViewController)
        }
    }

    override public func hideNavBars() {
        super.hideNavBars()
        positionNavBar(navigationBar, visible: false)
        updateInsets()
    }

    // MARK : private

    private func reloadEntirePostDetail() {
        localToken = streamViewController.resetInitialPageLoadingToken()

        PostService().loadPost(
            postParam,
            success: { (post, responseConfig) in
                if !self.streamViewController.isValidInitialPageLoadingToken(self.localToken) { return }
                self.postLoaded(post, responseConfig: responseConfig)
            },
            failure: { (error, statusCode) in
                if let deeplinkPath = self.deeplinkPath,
                    deeplinkURL = NSURL(string: deeplinkPath)
                {
                    UIApplication.sharedApplication().openURL(deeplinkURL)
                    self.deeplinkPath = nil
                    self.navigationController?.popViewControllerAnimated(true)
                }
                else {
                   self.showPostLoadFailure()
                }
                self.streamViewController.doneLoading()
            }
        )
    }

    private func showPostLoadFailure() {
        let message = NSLocalizedString("Something went wrong. Thank you for your patience with Ello Beta!", comment: "Initial stream load failure")
        let alertController = AlertViewController(message: message)
        let action = AlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .Dark) { _ in
            self.navigationController?.popViewControllerAnimated(true)
        }
        alertController.addAction(action)
        self.presentViewController(alertController, animated: true, completion: nil)
    }

    private func setupNavigationBar() {
        navigationBar = ElloNavigationBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: ElloNavigationBar.Size.height))
        navigationBar.autoresizingMask = [.FlexibleBottomMargin, .FlexibleWidth]
        view.addSubview(navigationBar)
        let item = UIBarButtonItem.backChevronWithTarget(self, action: Selector("backTapped:"))
        elloNavigationItem.leftBarButtonItems = [item]
        elloNavigationItem.fixNavBarItemPadding()
        navigationBar.items = [elloNavigationItem]
        assignRightButton()
    }

    private func assignRightButton() {
        if post == nil {
            elloNavigationItem.rightBarButtonItems = []
        }
        else {
            if isOwnPost() {
                elloNavigationItem.rightBarButtonItems = [
                    UIBarButtonItem(image: .XBox, target: self, action: Selector("deletePost")),
                    UIBarButtonItem(image: .Pencil, target: self, action: Selector("editPost")),
                ]
            }
            else {
                elloNavigationItem.rightBarButtonItems = [
                    UIBarButtonItem(image: .Dots, target: self, action: Selector("flagPost"))
                ]
            }
        }
    }

    private func postLoaded(post: Post, responseConfig: ResponseConfig) {
        if self.post == nil {
            Tracker.sharedTracker.postViewed(post.id)
        }
        self.post = post
        // need to reassign the userParam to the id for paging
        postParam = post.id
        // need to reassign the streamKind so that the comments can page based off the post.id from the ElloAPI.path
        // same for when tapping on a post token in a post this will replace '~CRAZY-TOKEN' with the correct id for paging to work
        streamViewController.streamKind = .PostDetail(postParam: postParam)
        streamViewController.responseConfig = responseConfig
        // clear out this view
        streamViewController.clearForInitialLoad()
        // set name
        title = post.author?.atName ?? "Post Detail"
        let parser = StreamCellItemParser()
        var items = parser.parse([post], streamKind: streamViewController.streamKind, currentUser: currentUser)

        var loversModel: UserAvatarCellModel?
        // add lovers and reposters
        if let lovers = post.lovesCount where lovers > 0 {
            items.append(StreamCellItem(jsonable: JSONAble.fromJSON([:], fromLinked: false), type: .Spacer(height: 4.0)))
            loversModel = UserAvatarCellModel(icon: .Heart, seeMoreTitle: NSLocalizedString("Loved by", comment: "Loved by title"), indexPath: NSIndexPath(forItem: items.count, inSection: 0))
            loversModel!.endpoint = .PostLovers(postId: post.id)
            items.append(StreamCellItem(jsonable: loversModel!, type: .UserAvatars))
        }
        var repostersModel: UserAvatarCellModel?
        if let reposters = post.repostsCount where reposters > 0 {
            if loversModel == nil {
                items.append(StreamCellItem(jsonable: JSONAble.fromJSON([:], fromLinked: false), type: .Spacer(height: 4.0)))
            }
            repostersModel = UserAvatarCellModel(icon: .Repost, seeMoreTitle: NSLocalizedString("Reposted by", comment: "Reposted by title"), indexPath: NSIndexPath(forItem: items.count, inSection: 0))
            repostersModel!.endpoint = .PostReposters(postId: post.id)
            items.append(StreamCellItem(jsonable: repostersModel!, type: .UserAvatars))
        }

        if loversModel != nil || repostersModel != nil {
            items.append(StreamCellItem(jsonable: JSONAble.fromJSON([:], fromLinked: false), type: .Spacer(height: 8.0)))
        }

        // add in the comment button if we have a current user
        if let currentUser = currentUser {
            items.append(StreamCellItem(jsonable: ElloComment.newCommentForPost(post, currentUser: currentUser), type: .CreateComment))
        }

        if let comments = post.comments {
            items += parser.parse(comments, streamKind: streamViewController.streamKind, currentUser: currentUser)
        }

        if scrollLogic != nil {
            scrollLogic.prevOffset = streamViewController.collectionView.contentOffset
        }
        // this calls doneLoading when cells are added
        streamViewController.appendUnsizedCellItems(items, withWidth: view.frame.width) { _ in
            if let lm = loversModel {
                self.addAvatarsView(lm)
            }

            if let rm = repostersModel {
                self.addAvatarsView(rm)
            }

            if let scrollToComment = self.scrollToComment {
                // nextTick didn't work, the collection view hadn't shown its
                // cells or updated contentView.  so this.
                delay(0.1) {
                    self.scrollToComment(scrollToComment)
                }
            }
        }

        assignRightButton()

        if isOwnPost() {
            showNavBars(false)
        }

        Tracker.sharedTracker.postLoaded(post.id)
    }

    private func scrollToComment(comment: Comment) {
        let commentItem = streamViewController.dataSource.visibleCellItems.find { item in
            return (item.jsonable as? Comment)?.id == comment.id
        } ?? streamViewController.dataSource.visibleCellItems.last

        if let commentItem = commentItem, indexPath = self.streamViewController.dataSource.indexPathForItem(commentItem) {
            self.streamViewController.collectionView.scrollToItemAtIndexPath(
                indexPath,
                atScrollPosition: .Top,
                animated: true
            )
        }
    }

    private func addAvatarsView(model: UserAvatarCellModel) {
        if !streamViewController.isValidInitialPageLoadingToken(localToken) { return }
        StreamService().loadStream(
            model.endpoint!,
            streamKind: streamViewController.streamKind,
            success: { (jsonables, responseConfig) in
                if !self.streamViewController.isValidInitialPageLoadingToken(self.localToken) { return }
                if let users = jsonables as? [User] {
                    model.users = users
                    if self.streamViewController.initialDataLoaded {
                        self.streamViewController.collectionView.reloadItemsAtIndexPaths([model.indexPath])
                    }
                }
            })
    }

    override public func postTapped(post: Post) {
        if let selfPost = self.post {
            if post.id != selfPost.id {
                super.postTapped(post)
            }
        }
    }

    private func isOwnPost() -> Bool {
        guard let post = post, currentUser = currentUser else {
            return false
        }
        return currentUser.id == post.authorId
    }

    public func flagPost() {
        guard let post = post else {
            return
        }

        let flagger = ContentFlagger(presentingController: self,
            flaggableId: post.id,
            contentType: .Post,
            commentPostId: nil)
        flagger.displayFlaggingSheet()
    }

    public func editPost() {
        guard let post = post where isOwnPost() else {
            return
        }

        // This is a bit dirty, we should not call a method on a compositionally held
        // controller's createPostDelegate. Can this use the responder chain when we have
        // parameters to pass?
        editPost(post, fromController: self)
    }

    public func deletePost() {
        guard let post = post, currentUser = currentUser where isOwnPost() else {
            return
        }

        let message = NSLocalizedString("Delete Post?", comment: "Delete Post")
        let alertController = AlertViewController(message: message)

        let yesAction = AlertAction(title: NSLocalizedString("Yes", comment: "Yes"), style: .Dark) { _ in
            if let userPostCount = currentUser.postsCount {
                currentUser.postsCount = userPostCount - 1
                postNotification(CurrentUserChangedNotification, value: currentUser)
            }

            postNotification(PostChangedNotification, value: (post, .Delete))
            PostService().deletePost(post.id,
                success: nil,
                failure: { (error, statusCode)  in
                    // TODO: add error handling
                    print("failed to delete post, error: \(error.elloErrorMessage ?? error.localizedDescription)")
                }
            )
        }
        let noAction = AlertAction(title: NSLocalizedString("No", comment: "No"), style: .Light, handler: .None)

        alertController.addAction(yesAction)
        alertController.addAction(noAction)

        logPresentingAlert("PostDetailViewController")
        self.presentViewController(alertController, animated: true, completion: .None)
    }

}
