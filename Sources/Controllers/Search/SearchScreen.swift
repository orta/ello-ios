//
//  SearchScreen.swift
//  Ello
//
//  Created by Colin Gray on 4/21/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

@objc
public protocol SearchScreenDelegate {
    func searchCanceled()
    func searchFieldCleared()
    func searchFieldChanged(text: String, isPostSearch: Bool)
    func toggleChanged(text: String, isPostSearch: Bool)
    func findFriendsTapped()
}

@objc
public protocol SearchScreenProtocol {
    var delegate : SearchScreenDelegate? { get set }
    func viewForStream() -> UIView
    func updateInsets(#bottom: CGFloat)
}

public class SearchScreen: UIView, SearchScreenProtocol {
    var keyboardWillShowObserver: NotificationObserver?
    var keyboardWillHideObserver: NotificationObserver?
    private var throttled: ThrottledBlock
    public private(set) var navigationBar: ElloNavigationBar!
    public private(set) var searchField: UITextField!
    private var searchControlsContainer: UIView!
    private var postsToggleButton: OutlineElloButton?
    private var peopleToggleButton: OutlineElloButton?
    private var streamViewContainer: UIView!
    public private(set) var findFriendsContainer: UIView!
    private var bottomInset: CGFloat
    private var navBarTitle: String!
    private var fieldPlaceholderText: String!
    private var isSearchView = true

    weak public var delegate : SearchScreenDelegate?

// MARK: init

    public init(frame: CGRect, isSearchView: Bool = true, navBarTitle: String? = NSLocalizedString("Search", comment: "Search navbar title"), fieldPlaceholderText: String? = NSLocalizedString("Search Ello", comment: "search ello placeholder text")) {
        throttled = debounce(0.5)
        bottomInset = 0
        self.navBarTitle = navBarTitle
        self.fieldPlaceholderText = fieldPlaceholderText
        self.isSearchView = isSearchView
        super.init(frame: frame)
        self.backgroundColor = UIColor.whiteColor()
        setupNavigationBar()
        searchControlsContainer = UIView(frame: self.frame.inset(sides: 15).atY(75).withHeight(41))
        setupSearchField()
        if self.isSearchView { setupToggleButtons() }
        setupStreamView()
        setupFindFriendsButton()
        findFriendsContainer.hidden = !self.isSearchView
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func showNavBars() {
        animate(animated: true) {
            self.searchControlsContainer.frame = self.frame.inset(sides: 15).atY(75).withHeight(self.searchControlsContainer.frame.size.height)
            self.streamViewContainer.frame = self.getStreamViewFrame()
        }
    }

    public func hideNavBars() {
        animate(animated: true) {
            self.searchControlsContainer.frame = self.frame.inset(sides: 15).atY(11).withHeight(self.searchControlsContainer.frame.size.height)
            self.streamViewContainer.frame = self.getStreamViewFrame()
        }
    }

// MARK: views

    private func setupNavigationBar() {
        let frame = CGRect(x: 0, y: 0, width: self.frame.width, height: ElloNavigationBar.Size.height)
        navigationBar = ElloNavigationBar(frame: frame)
        navigationBar.autoresizingMask = .FlexibleBottomMargin | .FlexibleWidth

        let navigationItem = UINavigationItem(title: navBarTitle)
        let leftItem = UIBarButtonItem.backChevronWithTarget(self, action: Selector("backTapped"))
        navigationItem.leftBarButtonItems = [leftItem]
        navigationItem.fixNavBarItemPadding()
        navigationBar.items = [navigationItem]

        self.addSubview(navigationBar)
    }

    private func setupSearchField() {
        searchField = UITextField(frame: CGRect(x: 0, y: 0, width: searchControlsContainer.frame.size.width, height: 41))
        searchField.autoresizingMask = .FlexibleWidth | .FlexibleBottomMargin
        searchField.clearButtonMode = .WhileEditing
        searchField.font = UIFont.regularBoldFont(18)
        searchField.textColor = UIColor.blackColor()
        searchField.attributedPlaceholder = NSAttributedString(string: "  \(fieldPlaceholderText)", attributes: [NSForegroundColorAttributeName: UIColor.greyA()])
        searchField.autocapitalizationType = .None
        searchField.autocorrectionType = .No
        searchField.spellCheckingType = .No
        searchField.enablesReturnKeyAutomatically = true
        searchField.returnKeyType = .Search
        searchField.keyboardType = .Default
        searchField.delegate = self
        searchField.addTarget(self, action: Selector("searchFieldDidChange"), forControlEvents: .EditingChanged)
        searchControlsContainer.addSubview(searchField)

        let lineFrame = searchField.frame.fromBottom().growUp(1).shiftUp(2)
        let lineView = UIView(frame: lineFrame)
        lineView.backgroundColor = UIColor.greyA()
        searchControlsContainer.addSubview(lineView)
        addSubview(searchControlsContainer)
    }

    private func setupToggleButtons() {
        let btnWidth = (searchControlsContainer.bounds.size.width - 10) / 2
        searchControlsContainer.frame.size.height += 73
        let postsBtn = OutlineElloButton(frame: CGRect(x: 0, y: 60, width: btnWidth, height: 33))
        postsBtn.setTitle(NSLocalizedString("Posts", comment: "Posts search toggle"), forState: .Normal)
        postsBtn.addTarget(self, action: Selector("onPostsTapped"), forControlEvents: .TouchUpInside)
        postsToggleButton = postsBtn
        searchControlsContainer.addSubview(postsBtn)

        let peopleBtn = OutlineElloButton(frame: CGRect(x: postsBtn.frame.maxX + 10, y: 60, width: btnWidth, height: 33))
        peopleBtn.setTitle(NSLocalizedString("People", comment: "People search toggle"), forState: .Normal)
        peopleBtn.addTarget(self, action: Selector("onPeopleTapped"), forControlEvents: .TouchUpInside)
        peopleToggleButton = peopleBtn
        searchControlsContainer.addSubview(peopleBtn)
        onPostsTapped()
    }

    public func onPostsTapped() {
        postsToggleButton?.selected = true
        peopleToggleButton?.selected = false
        delegate?.toggleChanged(searchField.text ?? "", isPostSearch: postsToggleButton?.selected ?? false)
    }

    public func onPeopleTapped() {
        peopleToggleButton?.selected = true
        postsToggleButton?.selected = false
        delegate?.toggleChanged(searchField.text ?? "", isPostSearch: postsToggleButton?.selected ?? false)
    }

    private func setupStreamView() {
        streamViewContainer = UIView(frame: getStreamViewFrame())
        streamViewContainer.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        streamViewContainer.backgroundColor = .whiteColor()
        self.addSubview(streamViewContainer)
    }

    private func getStreamViewFrame() -> CGRect {
        let height = frame.height - (searchControlsContainer.frame.maxY)
        return frame.atY(searchControlsContainer.frame.maxY).withHeight(height)
    }

    private func setupFindFriendsButton() {
        let height = CGFloat(143)
        let containerFrame = self.frame.fromBottom().growUp(height)
        findFriendsContainer = UIView(frame: containerFrame)
        findFriendsContainer.backgroundColor = .blackColor()

        let margins = UIEdgeInsets(top: 20, left: 15, bottom: 26, right: 15)
        let buttonHeight = CGFloat(50)
        let button = WhiteElloButton(frame: CGRect(
            x: margins.left,
            y: containerFrame.height - margins.bottom - buttonHeight,
            width: containerFrame.width - margins.left - margins.right,
            height: buttonHeight
            ))
        button.setTitle(NSLocalizedString("Find your friends", comment: "Find your friends button title"), forState: .Normal)
        button.addTarget(self, action: Selector("findFriendsTapped"), forControlEvents: .TouchUpInside)

        let label = ElloLabel()
        label.frame = CGRect(
            x: margins.left, y: 0,
            width: button.frame.width,
            height: containerFrame.height - margins.bottom - button.frame.height
        )
        label.numberOfLines = 2
        label.setLabelText(NSLocalizedString("Ello is better with friends.\nFind or invite yours:", comment: "Ello is better with friends button title"))

        self.addSubview(findFriendsContainer)
        findFriendsContainer.addSubview(label)
        findFriendsContainer.addSubview(button)
    }

    public func viewForStream() -> UIView {
        return streamViewContainer
    }

    private func clearSearch() {
        delegate?.searchFieldCleared()
        throttled {}
    }

    public func updateInsets(#bottom: CGFloat) {
        bottomInset = bottom
        setNeedsLayout()
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        findFriendsContainer.frame.origin.y = frame.size.height - findFriendsContainer.frame.height - bottomInset - ElloTabBar.Size.height
    }

    public func searchForText() {
        let text = searchField.text ?? ""
        if count(text) == 0 { return }
        hideFindFriends()
        delegate?.searchFieldChanged(text, isPostSearch: postsToggleButton?.selected ?? false)
    }

// MARK: actions

    @objc
    private func backTapped() {
        delegate?.searchCanceled()
    }

    @objc
    private func findFriendsTapped() {
        delegate?.findFriendsTapped()
    }

    @objc
    private func searchFieldDidChange() {
        let text = searchField.text ?? ""
        if count(text) == 0 {
            clearSearch()
            showFindFriends()
        }
        else {
            throttled { [unowned self] in
                self.searchForText()
            }
        }
    }

}

extension SearchScreen: UITextFieldDelegate {

    @objc
    public func textFieldShouldClear(textField: UITextField) -> Bool {
        clearSearch()
        showFindFriends()
        return true
    }

    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}

extension SearchScreen {

    private func showFindFriends() {
        findFriendsContainer.hidden = !isSearchView
    }

    private func hideFindFriends() {
        findFriendsContainer.hidden = true
    }

}
