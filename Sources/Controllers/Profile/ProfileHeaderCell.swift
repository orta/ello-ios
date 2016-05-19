//
//  ProfileHeaderCell.swift
//  Ello
//
//  Created by Ryan Boyajian on 2/12/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

@objc
public protocol EditProfileResponder {
    func onEditProfile()
}

@objc
public protocol PostsTappedResponder {
    func onPostsTapped()
}

public class ProfileHeaderCell: UICollectionViewCell {
    static let reuseIdentifier = "ProfileHeaderCell"

    typealias WebContentReady = (webView: UIWebView) -> Void

    // this little hack prevents constraints from breaking on initial load
    override public var bounds: CGRect {
        didSet {
          contentView.frame = bounds
        }
    }

    @IBOutlet weak var avatarImage: FLAnimatedImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var nameLabel: ElloLabel!
    @IBOutlet weak var viewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var webViewHeight: NSLayoutConstraint!
    @IBOutlet weak var bioWebView: UIWebView!
    @IBOutlet weak var postsButton: TwoLineButton!
    @IBOutlet weak var followersButton: TwoLineButton!
    @IBOutlet weak var followingButton: TwoLineButton!
    @IBOutlet weak var lovesButton: TwoLineButton!

    weak var webLinkDelegate: WebLinkDelegate?
    weak var simpleStreamDelegate: SimpleStreamDelegate?
    var user: User?
    var currentUser: User?
    var webContentReady: WebContentReady?

    override public func awakeFromNib() {
        super.awakeFromNib()
        style()
        bioWebView.delegate = self
    }

    func onWebContentReady(handler: WebContentReady?) {
        webContentReady = handler
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        avatarImage.layer.cornerRadius = avatarImage.bounds.size.height / CGFloat(2)
        bioWebView.scrollView.scrollEnabled = false
        bioWebView.scrollView.scrollsToTop = false
    }

    override public func prepareForReuse() {
        super.prepareForReuse()
        setAvatar(nil)
        bioWebView.stopLoading()
    }

    func setAvatar(image: UIImage?) {
        avatarImage.pin_cancelImageDownload()
        avatarImage.image = image
    }

    func setAvatarURL(url: NSURL) {
        setAvatar(nil)
        avatarImage.pin_setImageFromURL(url) { result in }
    }

    private func style() {
        usernameLabel.font = UIFont.defaultBoldFont(18)
        usernameLabel.textColor = UIColor.blackColor()

        nameLabel.font = UIFont.defaultFont()
        nameLabel.textColor = UIColor.greyA()
        nameLabel.lineBreakMode = .ByWordWrapping
    }

    @IBAction func editProfileTapped(sender: UIButton) {
        let responder = targetForAction(#selector(EditProfileResponder.onEditProfile), withSender: self) as? EditProfileResponder
        responder?.onEditProfile()
    }

    @IBAction func followingTapped(sender: UIButton) {
        if let user = user {
            let noResultsTitle: String
            let noResultsBody: String
            if user.id == currentUser?.id {
                noResultsTitle = InterfaceString.Following.CurrentUserNoResultsTitle
                noResultsBody = InterfaceString.Following.CurrentUserNoResultsBody
            }
            else {
                noResultsTitle = InterfaceString.Following.NoResultsTitle
                noResultsBody = InterfaceString.Following.NoResultsBody
            }
            simpleStreamDelegate?.showSimpleStream(.UserStreamFollowing(userId: user.id), title: InterfaceString.Following.Title, noResultsMessages: (title: noResultsTitle, body: noResultsBody))
        }
    }

    @IBAction func followersTapped(sender: UIButton) {
        if let user = user {
            let noResultsTitle: String
            let noResultsBody: String
            if user.id == currentUser?.id {
                noResultsTitle = InterfaceString.Followers.CurrentUserNoResultsTitle
                noResultsBody = InterfaceString.Followers.CurrentUserNoResultsBody
            }
            else {
                noResultsTitle = InterfaceString.Followers.NoResultsTitle
                noResultsBody = InterfaceString.Followers.NoResultsBody
            }
            simpleStreamDelegate?.showSimpleStream(.UserStreamFollowers(userId: user.id), title: InterfaceString.Followers.Title, noResultsMessages: (title: noResultsTitle, body: noResultsBody))
        }
    }

    @IBAction func lovesTapped(sender: UIButton) {
        if let user = user {
            let noResultsTitle: String
            let noResultsBody: String
            if user.id == currentUser?.id {
                noResultsTitle = InterfaceString.Loves.CurrentUserNoResultsTitle
                noResultsBody = InterfaceString.Loves.CurrentUserNoResultsBody
            }
            else {
                noResultsTitle = InterfaceString.Loves.NoResultsTitle
                noResultsBody = InterfaceString.Loves.NoResultsBody
            }
            simpleStreamDelegate?.showSimpleStream(.Loves(userId: user.id), title: InterfaceString.Loves.Title, noResultsMessages: (title: noResultsTitle, body: noResultsBody))
        }
    }

    @IBAction func postsTapped(sender: UIButton) {
        let responder = targetForAction(#selector(PostsTappedResponder.onPostsTapped), withSender: self) as? PostsTappedResponder
        responder?.onPostsTapped()
    }
}

extension ProfileHeaderCell: UIWebViewDelegate {
    public func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        return ElloWebViewHelper.handleRequest(request, webLinkDelegate: webLinkDelegate)
    }

    public func webViewDidFinishLoad(webView: UIWebView) {
        UIView.animateWithDuration(0.15) {
            self.contentView.alpha = 1.0
        }
        webContentReady?(webView: webView)
    }
}
